import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyflow/features/task/data/models/task_model.dart';

class TaskRemoteDatasource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  TaskRemoteDatasource({required this.firestore, required this.auth});

  Stream<List<TaskModel>> getTasksStream() {
    final userId = auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);
    
    return firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TaskModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> addTask(TaskModel task) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) throw Exception("User not logged in");
    
    final taskWithUser = task.toMap();
    taskWithUser['userId'] = userId; // Force user ID

    // Nếu id rỗng, tạo document mới lấy ID tự động
    final docRef = task.id.isEmpty 
      ? firestore.collection('tasks').doc() 
      : firestore.collection('tasks').doc(task.id);
      
    final taskData = task.toMap();
    await docRef.set(taskData);
  }

  Future<void> updateTask(TaskModel task) async {
    await firestore.collection('tasks').doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String id) async {
    await firestore.collection('tasks').doc(id).delete();
  }
}
