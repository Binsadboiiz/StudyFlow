import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyflow/features/auth/data/models/user_model.dart';

class AuthRemoteDatasource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRemoteDatasource({required this.auth, required this.firestore});

  Stream<String?> get authStateChanges => auth.authStateChanges().map((user) => user?.uid);

  Future<String> registerWithEmailAndPassword(String email, String password) async {
    final userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
    return userCredential.user!.uid;
  }

  Future<String?> loginWithEmailAndPassword(String email, String password) async {
    final userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user?.uid;
  }

  String? get currentUserId => auth.currentUser?.uid;

  Future<void> logout() async {
    await auth.signOut();
  }

  Future<void> saveUserToFirestore(UserModel user) async {
    await firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUserFromFirestore(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<bool> isUsernameExists(String username) async {
    final query = await firestore.collection('users').where('username', isEqualTo: username).limit(1).get();
    return query.docs.isNotEmpty;
  }
}
