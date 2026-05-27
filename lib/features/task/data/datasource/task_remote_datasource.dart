import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyflow/features/task/data/models/task_model.dart';

/// Data source for managing task operations with Firebase Firestore.
class TaskRemoteDatasource {
  /// The Firestore instance.
  final FirebaseFirestore firestore;
  
  /// The FirebaseAuth instance.
  final FirebaseAuth auth;

  TaskRemoteDatasource({required this.firestore, required this.auth});

  /// Gets a continuous stream of the user's tasks.
  Stream<List<TaskModel>> getTasksStream() {
    final userId = auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  /// Adds a new task to Firestore.
  Future<void> addTask(TaskModel task) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) throw Exception("User not logged in");

    final docRef = task.id.isEmpty
        ? firestore.collection('tasks').doc()
        : firestore.collection('tasks').doc(task.id);

    final taskData = task.toMap();
    taskData['userId'] = userId;
    await docRef.set(taskData);
  }

  /// Updates an existing task in Firestore.
  Future<void> updateTask(TaskModel task) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) throw Exception("User not logged in");

    final taskData = task.toMap();
    taskData['userId'] = userId;

    await firestore.collection('tasks').doc(task.id).update(taskData);
    await _updateStreakIfDailyGoalCompleted(userId, task);
  }

  /// Deletes a task from Firestore by its [id].
  Future<void> deleteTask(String id) async {
    await firestore.collection('tasks').doc(id).delete();
  }

  /// Updates the user's streak if all daily goals are completed.
  Future<void> _updateStreakIfDailyGoalCompleted(
    String userId,
    TaskModel updatedTask,
  ) async {
    final today = _dateOnly(DateTime.now());
    final taskDate = _dateOnly(updatedTask.date);

    if (!updatedTask.isCompleted || taskDate != today) return;

    final tasksSnapshot = await firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .get();

    final todayTasks = tasksSnapshot.docs.where((doc) {
      final dateValue = doc.data()['date'];
      if (dateValue is! String) return false;

      return _dateOnly(DateTime.parse(dateValue)) == today;
    }).toList();

    if (todayTasks.isEmpty ||
        todayTasks.any((doc) => doc.data()['isCompleted'] != true)) {
      return;
    }

    final userRef = firestore.collection('users').doc(userId);
    await firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists || userSnapshot.data() == null) return;

      final userData = userSnapshot.data()!;
      final lastStreakDate = _parseDate(userData['lastStreakDate']);
      final lastStreakDay = lastStreakDate != null
          ? _dateOnly(lastStreakDate)
          : null;

      if (lastStreakDay == today) return;

      final yesterday = today.subtract(const Duration(days: 1));
      final currentStreak = userData['streak'] is int
          ? userData['streak'] as int
          : 0;
      final nextStreak = lastStreakDay == yesterday ? currentStreak + 1 : 1;

      transaction.update(userRef, {
        'streak': nextStreak,
        'lastStreakDate': today.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    });
  }

  /// Returns a [DateTime] with only year, month, and day.
  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Parses a dynamic date value into a [DateTime] object.
  DateTime? _parseDate(dynamic value) {
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
