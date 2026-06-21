import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isar_community/isar.dart';
import 'package:studyflow/core/database/isar_service.dart';
import 'package:studyflow/core/di/injection.dart';
import 'package:studyflow/core/network/api_constants.dart';
import 'package:studyflow/features/focus/data/models/focus_session_model.dart';
import 'package:studyflow/features/focus/data/models/focus_session_isar_model.dart';

class FocusRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FocusRepository() {
    // Tự động đồng bộ các focus session offline khi internet online trở lại
    DependencyInjection.connectionService.addListener(_onConnectionStatusChanged);
  }

  void _onConnectionStatusChanged() {
    if (DependencyInjection.connectionService.isOnline) {
      debugPrint('Internet khôi phục, tự động chạy đồng bộ offline focus sessions...');
      syncAllPending();
    }
  }

  /// Lấy danh sách focus sessions cục bộ từ Isar
  Future<List<FocusSessionModel>> _getLocalFocusSessions() async {
    final isar = IsarService.isar;
    final localModels = await isar.focusSessionIsarModels
        .where()
        .findAll();
    localModels.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return localModels.map((model) => model.toDomain()).toList();
  }

  Future<FocusSessionModel?> saveFocusSession(FocusSessionModel session) async {
    final isar = IsarService.isar;
    final tempId = session.id.isEmpty ? DateTime.now().microsecondsSinceEpoch.toString() : session.id;
    final sessionWithId = FocusSessionModel(
      id: tempId,
      userId: session.userId,
      startTime: session.startTime,
      endTime: session.endTime,
      durationMinutes: session.durationMinutes,
      mode: session.mode,
      createdAt: session.createdAt,
    );

    final localModel = FocusSessionIsarModel.fromDomain(sessionWithId, syncStatus: 'pending_insert');

    try {
      // 1. Lưu local trước ngay lập tức
      await isar.writeTxn(() async {
        await isar.focusSessionIsarModels.put(localModel);
      });

      // 2. Cố gắng gửi API nếu online
      if (DependencyInjection.connectionService.isOnline) {
        try {
          final headers = await ApiConstants.getAuthHeaders(_auth);
          final response = await http.post(
            Uri.parse('${ApiConstants.baseUrl}/Focus/sessions'),
            headers: headers,
            body: jsonEncode(sessionWithId.toJson()),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            final remoteSession = FocusSessionModel.fromJson(jsonDecode(response.body));
            
            // Xóa local record tạm offline và ghi record đã sync từ server
            await isar.writeTxn(() async {
              final modelToDelete = await isar.focusSessionIsarModels.filter().uuidEqualTo(tempId).findFirst();
              if (modelToDelete != null) {
                await isar.focusSessionIsarModels.delete(modelToDelete.id);
              }
              final syncedModel = FocusSessionIsarModel.fromDomain(remoteSession, syncStatus: 'synced');
              await isar.focusSessionIsarModels.put(syncedModel);
            });
            return remoteSession;
          }
        } catch (e) {
          debugPrint('Lỗi lưu focus session lên server, lưu tạm offline: $e');
        }
      }
      return sessionWithId;
    } catch (e) {
      debugPrint('Lỗi lưu focus session: $e');
      return null;
    }
  }

  Future<List<DailyFocusHeatmapModel>> getHeatmapData(DateTime startDate, DateTime endDate) async {
    // 1. Nếu online, cố gắng lấy dữ liệu từ API
    if (DependencyInjection.connectionService.isOnline) {
      try {
        final headers = await ApiConstants.getAuthHeaders(_auth);
        final start = startDate.toIso8601String();
        final end = endDate.toIso8601String();
        
        final response = await http.get(
          Uri.parse('${ApiConstants.baseUrl}/Focus/heatmap?startDate=$start&endDate=$end'),
          headers: headers,
        );

        if (response.statusCode == 200) {
          final List<dynamic> jsonList = jsonDecode(response.body);
          return jsonList.map((json) => DailyFocusHeatmapModel.fromJson(json)).toList();
        }
      } catch (e) {
        debugPrint('Lỗi tải dữ liệu heatmap từ API, chuyển sang tính toán offline: $e');
      }
    }

    // 2. Tính toán offline dựa trên dữ liệu các session đã lưu ở Isar
    try {
      final localSessions = await _getLocalFocusSessions();
      
      // Lọc các session trong phạm vi ngày
      final filteredSessions = localSessions.where((s) {
        final startDay = DateTime(startDate.year, startDate.month, startDate.day);
        final endDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        return s.startTime.isAfter(startDay) && s.startTime.isBefore(endDay);
      });

      // Nhóm theo ngày (YYYY-MM-DD) và cộng dồn durationMinutes
      final Map<String, int> heatmapMap = {};
      for (final session in filteredSessions) {
        final dateKey = "${session.startTime.year}-${session.startTime.month.toString().padLeft(2, '0')}-${session.startTime.day.toString().padLeft(2, '0')}";
        heatmapMap[dateKey] = (heatmapMap[dateKey] ?? 0) + session.durationMinutes;
      }

      // Map sang DailyFocusHeatmapModel
      return heatmapMap.entries.map((e) {
        return DailyFocusHeatmapModel(
          date: DateTime.parse(e.key),
          totalMinutes: e.value,
        );
      }).toList();
    } catch (e) {
      debugPrint('Lỗi tính toán heatmap offline: $e');
      return [];
    }
  }

  Future<List<FocusSessionModel>> getFocusSessions() async {
    try {
      // 1. Nếu offline, trả về local ngay lập tức
      if (!DependencyInjection.connectionService.isOnline) {
        return _getLocalFocusSessions();
      }

      // 2. Đồng bộ các session offline trước
      await syncAllPending();

      // 3. Tải dữ liệu mới nhất từ remote
      final headers = await ApiConstants.getAuthHeaders(_auth);
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/Focus/sessions'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final remoteSessions = jsonList.map((json) => FocusSessionModel.fromJson(json)).toList();

        final isar = IsarService.isar;
        await isar.writeTxn(() async {
          // Lấy danh sách local UUIDs để tránh xóa nhầm các record đang chờ đồng bộ offline
          final pendingModels = await isar.focusSessionIsarModels
              .filter()
              .syncStatusEqualTo('pending_insert')
              .findAll();
          final pendingUuids = pendingModels.map((m) => m.uuid).toSet();

          // Xóa các record đã synced cũ không còn nằm trong danh sách pending
          await isar.focusSessionIsarModels
              .filter()
              .syncStatusEqualTo('synced')
              .deleteAll();

          // Ghi đè dữ liệu mới từ Server vào Local Isar dưới dạng 'synced'
          for (final session in remoteSessions) {
            if (!pendingUuids.contains(session.id)) {
              final isarModel = FocusSessionIsarModel.fromDomain(session, syncStatus: 'synced');
              await isar.focusSessionIsarModels.put(isarModel);
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Lỗi đồng bộ/tải focus sessions: $e');
    }
    return _getLocalFocusSessions();
  }

  /// Đồng bộ toàn bộ các focus sessions đang chờ xử lý offline lên server
  Future<void> syncAllPending() async {
    if (!DependencyInjection.connectionService.isOnline) return;

    final isar = IsarService.isar;
    try {
      final pendingSessions = await isar.focusSessionIsarModels
          .filter()
          .syncStatusEqualTo('pending_insert')
          .findAll();

      for (final model in pendingSessions) {
        try {
          final domainSession = model.toDomain();
          final headers = await ApiConstants.getAuthHeaders(_auth);
          final response = await http.post(
            Uri.parse('${ApiConstants.baseUrl}/Focus/sessions'),
            headers: headers,
            body: jsonEncode(domainSession.toJson()),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            final remoteSession = FocusSessionModel.fromJson(jsonDecode(response.body));
            
            // Xóa local record tạm offline và ghi record đã sync từ server
            await isar.writeTxn(() async {
              await isar.focusSessionIsarModels.delete(model.id);
              final syncedModel = FocusSessionIsarModel.fromDomain(remoteSession, syncStatus: 'synced');
              await isar.focusSessionIsarModels.put(syncedModel);
            });
          }
        } catch (e) {
          debugPrint('Lỗi đồng bộ thêm focus session ${model.uuid}: $e');
        }
      }
    } catch (e) {
      debugPrint('Lỗi đồng bộ focus sessions: $e');
    }
  }
}
