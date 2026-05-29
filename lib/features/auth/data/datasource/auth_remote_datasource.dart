import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyflow/features/auth/data/models/user_model.dart';
import 'package:studyflow/core/network/api_constants.dart';

/// A remote data source class for handling authentication-related operations
/// using Firebase Authentication and Firestore.
class AuthRemoteDatasource {
  /// Instance of [FirebaseAuth] used for user authentication.
  final FirebaseAuth auth;
  
  /// Instance of [FirebaseFirestore] used for storing user data.
  final FirebaseFirestore firestore;

  /// Creates an [AuthRemoteDatasource] with the required Firebase instances.
  AuthRemoteDatasource({required this.auth, required this.firestore});

  /// A stream that emits the current user's UID whenever the authentication state changes.
  Stream<String?> get authStateChanges =>
      auth.authStateChanges().map((user) => user?.uid);

  /// A stream that emits the latest [UserModel] data from Firestore
  /// based on the current authenticated user.
  Stream<UserModel?> get userChanges {
    return auth.authStateChanges().asyncExpand((user) {
      // If no user is logged in, yield a null value stream.
      if (user == null) return Stream<UserModel?>.value(null);

      // Listen to the Firestore document corresponding to the authenticated user's UID.
      return firestore.collection('users').doc(user.uid).snapshots().map((doc) {
        if (!doc.exists || doc.data() == null) return null;
        return UserModel.fromMap(doc.data()!, doc.id);
      });
    });
  }

  /// Registers a new user with the provided [email] and [password].
  ///
  /// Returns the newly created user's UID.
  Future<String> registerWithEmailAndPassword(
    String email,
    String password,
    String fullName,
    String username,
  ) async {
    final userCredential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = userCredential.user!.uid;

    // Sync user with .NET Backend
    try {
      final token = await auth.currentUser?.getIdToken();
      final url = Uri.parse('${ApiConstants.baseUrl}/users/sync');
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': email,
          'username': username,
          'fullName': fullName,
        }),
      );
    } catch (e) {
      // Ignore sync error for now, or handle it depending on requirement
      print('Sync to Postgres failed: $e');
    }

    return uid;
  }

  /// Logs in an existing user using their [email] and [password].
  ///
  /// Returns the authenticated user's UID, or null if the process fails.
  Future<String?> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final userCredential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user?.uid;
  }

  /// Retrieves the current authenticated user's UID.
  String? get currentUserId => auth.currentUser?.uid;

  /// Logs out the currently authenticated user.
  Future<void> logout() async {
    await auth.signOut();
  }

  /// Saves the given [UserModel] data to Firestore.
  Future<void> saveUserToFirestore(UserModel user) async {
    await firestore.collection('users').doc(user.id).set(user.toMap());
  }

  /// Updates specific [fields] of a user document in Firestore identified by [uid].
  Future<void> updateUserFields(String uid, Map<String, dynamic> fields) async {
    await firestore.collection('users').doc(uid).update(fields);
  }

  /// Fetches a [UserModel] from Firestore using the provided [uid].
  ///
  /// Returns the [UserModel] if found, otherwise returns null.
  Future<UserModel?> getUserFromFirestore(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  /// Checks if a [username] is already taken by querying Firestore.
  ///
  /// Returns true if the username exists, false otherwise.
  Future<bool> isUsernameExists(String username) async {
    final query = await firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }
}
