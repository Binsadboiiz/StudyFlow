import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyflow/core/network/api_constants.dart';
import 'package:studyflow/features/scan/data/models/scanned_document_model.dart';
import 'package:studyflow/features/scan/data/models/storage_usage_model.dart';

/// Data source quản lý các thao tác CRUD tài liệu quét với .NET API.
/// Sử dụng http package và Firebase Auth token để xác thực.
class ScanRemoteDatasource {
  final FirebaseAuth auth;
  final String scanEndpoint = '${ApiConstants.baseUrl}/scanned-documents';

  ScanRemoteDatasource({required this.auth});

  /// Lấy danh sách tài liệu đã quét từ API.
  Future<List<ScannedDocumentModel>> getDocuments() async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    final response = await http.get(Uri.parse(scanEndpoint), headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      final data = responseBody['data'];
      List<dynamic> jsonList = [];
      if (data is Map<String, dynamic>) {
        // Backend returns pagination object { items, totalCount, ... }
        jsonList = data['items'] ?? data['Items'] ?? [];
      } else if (data is List) {
        jsonList = data;
      }
      return jsonList.map((json) => ScannedDocumentModel.fromJson(json)).toList();
    } else {
      throw Exception('Could not load document list from API');
    }
  }

  /// Tạo một tài liệu quét mới qua API.
  Future<ScannedDocumentModel> createDocument(Map<String, dynamic> data) async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    final response = await http.post(
      Uri.parse(scanEndpoint),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      return ScannedDocumentModel.fromJson(responseBody['data']);
    } else {
      throw Exception('Không thể tạo tài liệu mới');
    }
  }

  /// Lấy thông tin chi tiết một tài liệu theo ID.
  Future<ScannedDocumentModel?> getDocumentById(String id) async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    final response = await http.get(
      Uri.parse('$scanEndpoint/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      return ScannedDocumentModel.fromJson(responseBody['data']);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Không thể tải thông tin tài liệu');
    }
  }

  /// Cập nhật thông tin tài liệu qua API.
  Future<void> updateDocument(String id, Map<String, dynamic> data) async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    final response = await http.put(
      Uri.parse('$scanEndpoint/$id'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Không thể cập nhật tài liệu');
    }
  }

  /// Xóa một tài liệu qua API.
  Future<void> deleteDocument(String id) async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    final response = await http.delete(
      Uri.parse('$scanEndpoint/$id'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Không thể xóa tài liệu');
    }
  }

  /// Xóa vĩnh viễn tài liệu qua API.
  Future<void> hardDeleteDocument(String id) async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    final response = await http.delete(
      Uri.parse('$scanEndpoint/hard-delete/$id'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Không thể xóa vĩnh viễn tài liệu');
    }
  }

  /// Xóa hàng loạt tài liệu qua API.
  Future<void> batchDeleteDocuments(List<String> ids) async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    final response = await http.post(
      Uri.parse('$scanEndpoint/batch-delete'),
      headers: headers,
      body: json.encode(ids),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Không thể xóa hàng loạt tài liệu');
    }
  }

  /// Lấy danh sách tài liệu trong thùng rác từ API.
  Future<List<ScannedDocumentModel>> getTrashDocuments() async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    final response = await http.get(Uri.parse('$scanEndpoint/trash'), headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      final List<dynamic> jsonList = responseBody['data'] ?? [];
      return jsonList.map((json) => ScannedDocumentModel.fromJson(json)).toList();
    } else {
      throw Exception('Could not load trash documents from API');
    }
  }

  /// Phục hồi tài liệu từ thùng rác qua API.
  Future<void> restoreDocument(String id) async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    final response = await http.post(
      Uri.parse('$scanEndpoint/restore/$id'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Không thể phục hồi tài liệu');
    }
  }

  /// Tìm kiếm tài liệu theo từ khóa.
  Future<List<ScannedDocumentModel>> searchDocuments(String query) async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    final uri = Uri.parse('$scanEndpoint/search').replace(
      queryParameters: {'q': query},
    );
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      final List<dynamic> jsonList = responseBody['data'] ?? [];
      return jsonList.map((json) => ScannedDocumentModel.fromJson(json)).toList();
    } else {
      throw Exception('Không thể tìm kiếm tài liệu');
    }
  }

  /// Lấy thông tin sử dụng dung lượng lưu trữ.
  Future<StorageUsageModel> getStorageUsage() async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    final response = await http.get(
      Uri.parse('$scanEndpoint/storage-usage'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      return StorageUsageModel.fromJson(responseBody['data']);
    } else {
      throw Exception('Không thể tải thông tin dung lượng');
    }
  }
}
