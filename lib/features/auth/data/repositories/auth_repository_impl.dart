import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:studyflow/core/database/isar_service.dart';
import 'package:studyflow/core/di/injection.dart';
import 'package:isar_community/isar.dart';
import 'package:studyflow/core/network/api_constants.dart';
import 'package:studyflow/features/task/data/models/task_isar_model.dart';
import 'package:studyflow/features/flashcard/data/models/flashcard_set_isar_model.dart';
import 'package:studyflow/features/focus/data/models/focus_session_isar_model.dart';
import 'package:studyflow/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:studyflow/features/auth/data/models/user_model.dart';
import 'package:studyflow/features/auth/domain/entities/user_entity.dart';
import 'package:studyflow/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of [AuthRepository] that interacts with [AuthRemoteDatasource]
/// to handle authentication and user-related operations.
class AuthRepositoryImpl implements AuthRepository {
  /// The remote data source for authentication.
  final AuthRemoteDatasource remoteDatasource;

  /// Cache of the actual/real user avatar URL.
  String? _cachedAvatarUrl;

  /// Trigger to notify stream listeners that the local avatar cache has been updated.
  final StreamController<void> _cacheUpdateTrigger =
      StreamController<void>.broadcast();

  /// Creates an [AuthRepositoryImpl] instance with the required [remoteDatasource].
  AuthRepositoryImpl(this.remoteDatasource);

  /// Loads the cached avatar URL from SharedPreferences.
  Future<void> _loadAvatarCache(String userId) async {
    _cachedAvatarUrl = null; // Always reset first to prevent leaking old avatar
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedAvatarUrl = prefs.getString('user_avatar_$userId');
    } catch (_) {}
  }

  /// Updates the cached avatar URL and persists it to SharedPreferences.
  Future<void> _updateAvatarCache(String userId, String avatarUrl) async {
    try {
      _cachedAvatarUrl = avatarUrl;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_avatar_$userId', avatarUrl);
      _cacheUpdateTrigger.add(null);
    } catch (_) {}
  }

  /// Saves the user profile to local cache (SharedPreferences) as JSON.
  Future<void> _saveUserToCache(UserModel userModel) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = userModel.toMap();
      map['id'] = userModel.id; // Map doesn't include ID, manually write it
      await prefs.setString('cached_user_profile', jsonEncode(map));
    } catch (_) {}
  }

  /// Loads the user profile from local cache (SharedPreferences).
  Future<UserModel?> _loadUserFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString('cached_user_profile');
      if (cachedStr != null && cachedStr.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(cachedStr);
        final String docId = map['id'] ?? '';
        return UserModel.fromMap(map, docId);
      }
    } catch (_) {}
    return null;
  }

  /// Clears the cached user profile from SharedPreferences.
  Future<void> _clearUserCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_user_profile');
    } catch (_) {}
  }

  /// Converts a [UserModel] into a [UserEntity] for use in the domain layer.
  UserEntity _toEntity(UserModel userModel) {
    return UserEntity(
      id: userModel.id,
      username: userModel.username,
      email: userModel.email,
      fullName: userModel.fullName,
      photoUrl: (_cachedAvatarUrl != null && _cachedAvatarUrl!.isNotEmpty)
          ? _cachedAvatarUrl
          : (userModel.photoUrl ??
                'assets/images/3c67757cef723535a7484a6c7bfbfc43.jpg'),
      level: userModel.level,
      xp: userModel.xp,
      streak: _effectiveStreak(userModel),
      dailyTargetMinutes: userModel.dailyTargetMinutes,
      lastStreakDate: userModel.lastStreakDate,
      streakHistory: userModel.streakHistory,
      createdAt: userModel.createdAt,
      updatedAt: userModel.updatedAt,
    );
  }

  /// Calculates the effective streak of the user based on the current date.
  ///
  /// If the streak was not updated today or yesterday, it resets to 0.
  int _effectiveStreak(UserModel userModel) {
    final lastStreakDate = userModel.lastStreakDate;
    if (lastStreakDate == null) return 0;

    // Get date-only components to safely compare days without time interference.
    final today = _dateOnly(DateTime.now());
    final lastDay = _dateOnly(lastStreakDate);
    final yesterday = today.subtract(const Duration(days: 1));

    // The streak is valid if it was updated today or yesterday.
    if (lastDay == today || lastDay == yesterday) {
      return userModel.streak;
    }

    // Streak is broken.
    return 0;
  }

  /// Returns a [DateTime] with only the year, month, and day components.
  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  Future<void> register(UserEntity user, String password) async {
    // Check if the username is already taken.
    final usernameExists = await isUsernameExists(user.username);
    if (usernameExists) throw Exception("Username already exists");

    // Register the user with Firebase Authentication.
    final uid = await remoteDatasource.registerWithEmailAndPassword(
      user.email,
      password,
      user.fullName,
      user.username,
    );

    // Create a new UserModel with the generated UID.
    final userModel = UserModel(
      id: uid,
      username: user.username,
      email: user.email,
      fullName: user.fullName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save the new user data to Firestore.
    await remoteDatasource.saveUserToFirestore(userModel);
  }

  @override
  Future<UserEntity?> login(String email, String password) async {
    // Authenticate the user and get their UID.
    final uid = await remoteDatasource.loginWithEmailAndPassword(
      email,
      password,
    );
    if (uid == null) return null;

    // Load actual avatar URL from cache before converting to Entity
    await _loadAvatarCache(uid);

    // Fetch user details from Firestore.
    final userModel = await remoteDatasource.getUserFromFirestore(uid);
    if (userModel == null) return null;

    // Synchronize to the backend in case previous attempts failed (self-healing)
    await _syncUserToBackend(userModel);

    return _toEntity(userModel);
  }

  @override
  Future<bool> isUsernameExists(String username) async {
    return await remoteDatasource.isUsernameExists(username);
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    final controller = StreamController<UserEntity?>();
    StreamSubscription? userChangesSub;
    StreamSubscription? triggerSub;
    UserModel? lastModel;

    Future<void> emitLatest() async {
      if (lastModel == null) {
        if (!controller.isClosed) {
          controller.add(null);
        }
        return;
      }
      await _loadAvatarCache(lastModel!.id);
      if (!controller.isClosed) {
        controller.add(_toEntity(lastModel!));
      }
    }

    controller.onListen = () {
      // Fetch and emit cached user profile if available, for instant startup response
      _loadUserFromCache().then((cachedModel) async {
        if (cachedModel != null && lastModel == null) {
          lastModel = cachedModel;
          await emitLatest();
        } else if (cachedModel == null && lastModel == null) {
          // If no cached user profile, check if user is logged in via Firebase Auth
          final currentUid = remoteDatasource.currentUserId;
          if (currentUid != null) {
            final firebaseUser = remoteDatasource.auth.currentUser;
            lastModel = UserModel(
              id: currentUid,
              fullName: firebaseUser?.displayName ?? 'User',
              username: firebaseUser?.email?.split('@').first ?? 'user',
              email: firebaseUser?.email ?? '',
              streak: 0,
              lastStreakDate: DateTime.now(),
              streakHistory: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            await emitLatest();
          }
        }
      });

      userChangesSub = remoteDatasource.userChanges.listen((userModel) async {
        lastModel = userModel;
        await emitLatest();
        if (userModel != null) {
          await _saveUserToCache(userModel);
          // Asynchronously sync in background when Firestore model changes to load cache from Postgres.
          _syncUserToBackend(userModel);
        } else {
          await _clearUserCache();
        }
      });

      triggerSub = _cacheUpdateTrigger.stream.listen((_) {
        emitLatest();
      });
    };

    controller.onCancel = () {
      userChangesSub?.cancel();
      triggerSub?.cancel();
    };

    return controller.stream;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    // Get the currently authenticated UID.
    final uid = remoteDatasource.currentUserId;
    if (uid == null) return null;

    // Load actual avatar from cache
    await _loadAvatarCache(uid);

    // Try loading cached profile first to avoid initial UI freeze/block
    final cached = await _loadUserFromCache();
    if (cached != null && cached.id == uid) {
      // Return cached user immediately, sync backend in background
      _syncUserToBackend(cached);
      return _toEntity(cached);
    }

    // Fetch and return the corresponding user entity.
    final userModel = await remoteDatasource.getUserFromFirestore(uid);
    if (userModel == null) return null;

    await _saveUserToCache(userModel);

    // Sync with backend to heal database state and fetch the latest avatar URL from Postgres.
    await _syncUserToBackend(userModel);

    return _toEntity(userModel);
  }

  @override
  Future<void> updateUserStreak(
    int streak,
    DateTime lastStreakDate,
    List<String> streakHistory,
  ) async {
    final uid = remoteDatasource.currentUserId;
    if (uid == null) return;

    // Update the streak fields in Firestore.
    await remoteDatasource.updateUserFields(uid, {
      'streak': streak,
      'lastStreakDate': lastStreakDate.toIso8601String(),
      'streakHistory': streakHistory,
    });

    try {
      final user = remoteDatasource.auth.currentUser;
      if (user == null) return;
      final token = await user.getIdToken();
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/users/streak'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'streak': streak,
          'lastStreakDate': lastStreakDate.toIso8601String(),
          'streakHistory': streakHistory,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint(
          'Backend streak update returned status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Backend streak update failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    final uid = remoteDatasource.currentUserId;

    // Clear local cache immediately to prevent profile mismatch for the next user
    await _clearUserCache();
    _cachedAvatarUrl = null;

    if (uid != null) {
      final isar = IsarService.isar;
      try {
        await isar.writeTxn(() async {
          await isar.taskIsarModels.filter().userIdEqualTo(uid).syncStatusEqualTo('synced').deleteAll();
          await isar.flashcardSetIsarModels.filter().userIdEqualTo(uid).syncStatusEqualTo('synced').deleteAll();
          await isar.focusSessionIsarModels.filter().userIdEqualTo(uid).syncStatusEqualTo('synced').deleteAll();
        });
        debugPrint('Logged out: Synced local Isar records cleared for user $uid.');
      } catch (e) {
        debugPrint('Failed to clear synced local Isar records on logout: $e');
      }
    }

    // Clear in-memory task repository cache
    DependencyInjection.taskRepository.clearCache();

    // Log out the current user via the remote datasource.
    await remoteDatasource.logout();
  }

  @override
  Future<UserEntity?> loginWithGoogle() async {
    final userCredential = await remoteDatasource.signInWithGoogle();
    if (userCredential == null) return null;

    final user = userCredential.user;
    if (user == null) return null;

    // Load actual avatar URL from cache
    await _loadAvatarCache(user.uid);

    // Check if the user document already exists in Firestore
    var userModel = await remoteDatasource.getUserFromFirestore(user.uid);
    if (userModel == null) {
      // Create a unique username from email
      final email = user.email ?? '';
      String baseUsername = email.isNotEmpty ? email.split('@')[0] : 'user';
      String username = baseUsername;
      int count = 1;
      while (await remoteDatasource.isUsernameExists(username)) {
        username = '$baseUsername$count';
        count++;
      }

      final fullName = user.displayName ?? 'Google User';
      final photoUrl = user.photoURL;

      // Initialize user in Firestore (using local default avatar to prevent length limit issues)
      userModel = UserModel(
        id: user.uid,
        username: username,
        email: email,
        fullName: fullName,
        photoUrl: 'assets/images/3c67757cef723535a7484a6c7bfbfc43.jpg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await remoteDatasource.saveUserToFirestore(userModel);

      // Save initial actual avatar from Google to local cache so it syncs to Postgres
      if (photoUrl != null && photoUrl.isNotEmpty) {
        await _updateAvatarCache(user.uid, photoUrl);
      }
    }

    // Force sync user with .NET Backend on every login (self-healing)
    await _syncUserToBackend(userModel);

    return _toEntity(userModel);
  }

  /// Private helper method to handle idempotent synchronization to the backend (self-healing).
  Future<void> _syncUserToBackend(UserModel userModel) async {
    try {
      final user = remoteDatasource.auth.currentUser;
      if (user == null) return;
      final token = await user.getIdToken();
      final url = Uri.parse('${ApiConstants.baseUrl}/users/sync');

      // Load current cached avatar to sync to backend if Postgres is missing it
      final avatarToSync =
          (_cachedAvatarUrl != null && _cachedAvatarUrl!.isNotEmpty)
          ? _cachedAvatarUrl
          : (userModel.photoUrl ??
                'assets/images/3c67757cef723535a7484a6c7bfbfc43.jpg');

      // Fetch the actual local timezone dynamically
      String timezone = "Asia/Ho_Chi_Minh";
      try {
        timezone = await FlutterTimezone.getLocalTimezone();
      } catch (e) {
        debugPrint('Failed to dynamically fetch local timezone: $e');
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': userModel.email,
          'username': userModel.username,
          'fullName': userModel.fullName,
          'avatarUrl': avatarToSync,
          'timezone': timezone,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final realAvatarUrl = body['data']['avatarUrl'];
          if (realAvatarUrl != null && realAvatarUrl.isNotEmpty) {
            final oldAvatarUrl = _cachedAvatarUrl;
            await _updateAvatarCache(userModel.id, realAvatarUrl);
            if (oldAvatarUrl != realAvatarUrl) {
              _cacheUpdateTrigger.add(null);
            }
          }
        }
      }
    } catch (e) {
      // Log sync failure but do not crash the app, permitting subsequent self-healing attempts
      debugPrint('Self-healing sync to backend failed: $e');
    }
  }

  @override
  Future<void> updateProfile({
    required String fullName,
    String? photoUrl, // This is the actual avatar URL chosen by the user
    String? newPassword,
    String? currentPassword,
  }) async {
    final uid = remoteDatasource.currentUserId;
    if (uid == null) throw Exception("User not logged in");

    // Handle password change first if requested
    if (newPassword != null && newPassword.isNotEmpty) {
      if (currentPassword == null || currentPassword.isEmpty) {
        throw Exception("Current password is required to change password");
      }
      // Reauthenticate first
      await remoteDatasource.reauthenticate(currentPassword);
      // Update password
      await remoteDatasource.updatePassword(newPassword);
    }

    // Update Firebase display name & photo url (using default asset path in Auth profile)
    await remoteDatasource.updateFirebaseProfile(fullName, photoUrl);

    // Call PUT endpoint on Backend to save actual profile details in Postgres
    try {
      final user = remoteDatasource.auth.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        final url = Uri.parse('${ApiConstants.baseUrl}/users/profile');
        
        // Fetch the actual local timezone dynamically
        String timezone = "Asia/Ho_Chi_Minh";
        try {
          timezone = await FlutterTimezone.getLocalTimezone();
        } catch (e) {
          debugPrint('Failed to dynamically fetch local timezone: $e');
        }

        final response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'fullName': fullName,
            'avatarUrl':
                photoUrl ??
                'assets/images/3c67757cef723535a7484a6c7bfbfc43.jpg',
            'timezone': timezone,
          }),
        );

        if (response.statusCode != 200) {
          debugPrint(
            'Backend profile update returned status: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      debugPrint('Backend profile update failed: $e');
    }

    // Update local cache with actual avatar URL
    if (photoUrl != null && photoUrl.isNotEmpty) {
      await _updateAvatarCache(uid, photoUrl);
    }

    // Update Firestore user document (using default local avatar to prevent character limit errors)
    final updates = {
      'fullName': fullName,
      'photoUrl': 'assets/images/3c67757cef723535a7484a6c7bfbfc43.jpg',
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await remoteDatasource.updateUserFields(uid, updates);
  }
}
