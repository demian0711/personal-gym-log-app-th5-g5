import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _userId;

  void setUserId(String userId) {
    _userId = userId;
  }

  // ==========================================
  // --- TEMPLATES ---
  // ==========================================

  /// Upload a template to Firestore
  Future<void> uploadTemplate(Workout template) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('templates')
          .doc(template.id)
          .set(template.toMap());
      print('Template uploaded: ${template.id}');
    } catch (e) {
      print('Error uploading template: $e');
      rethrow;
    }
  }

  /// Download all templates from Firestore
  Future<List<Workout>> downloadTemplates() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('templates')
          .get();

      final List<Workout> templates = [];
      for (var doc in snapshot.docs) {
        templates.add(Workout.fromMap(doc.data()));
      }
      return templates;
    } catch (e) {
      print('Error downloading templates: $e');
      rethrow;
    }
  }

  /// Delete a template from Firestore
  Future<void> deleteTemplate(String templateId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('templates')
          .doc(templateId)
          .delete();
      print('Template deleted: $templateId');
    } catch (e) {
      print('Error deleting template: $e');
      rethrow;
    }
  }

  /// Listen to real-time template changes
  Stream<List<Workout>> streamTemplates() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('templates')
        .snapshots()
        .map((snapshot) {
          final List<Workout> templates = [];
          for (var doc in snapshot.docs) {
            templates.add(Workout.fromMap(doc.data()));
          }
          return templates;
        })
        .handleError((e) {
          print('Error streaming templates: $e');
          return [];
        });
  }

  // ==========================================
  // --- WORKOUT LOGS ---
  // ==========================================

  /// Upload a workout log to Firestore
  Future<void> uploadWorkoutLog(Workout log) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('workoutLogs')
          .doc(log.id)
          .set(log.toMap());
      print('Workout log uploaded: ${log.id}');
    } catch (e) {
      print('Error uploading workout log: $e');
      rethrow;
    }
  }

  /// Download all workout logs from Firestore
  Future<List<Workout>> downloadWorkoutLogs() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('workoutLogs')
          .orderBy('date', descending: true)
          .get();

      final List<Workout> logs = [];
      for (var doc in snapshot.docs) {
        logs.add(Workout.fromMap(doc.data()));
      }
      return logs;
    } catch (e) {
      print('Error downloading workout logs: $e');
      rethrow;
    }
  }

  /// Delete a workout log from Firestore
  Future<void> deleteWorkoutLog(String logId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('workoutLogs')
          .doc(logId)
          .delete();
      print('Workout log deleted: $logId');
    } catch (e) {
      print('Error deleting workout log: $e');
      rethrow;
    }
  }

  /// Listen to real-time workout log changes
  Stream<List<Workout>> streamWorkoutLogs() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('workoutLogs')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          final List<Workout> logs = [];
          for (var doc in snapshot.docs) {
            logs.add(Workout.fromMap(doc.data()));
          }
          return logs;
        })
        .handleError((e) {
          print('Error streaming workout logs: $e');
          return [];
        });
  }

  // ==========================================
  // --- SYNC OPERATIONS ---
  // ==========================================

  /// Sync all local data to Firestore
  Future<void> syncAllToFirebase(
    List<Workout> templates,
    List<Workout> workoutLogs,
  ) async {
    try {
      // Sync templates
      for (var template in templates) {
        await uploadTemplate(template);
      }

      // Sync workout logs
      for (var log in workoutLogs) {
        await uploadWorkoutLog(log);
      }

      print('All data synced to Firestore');
    } catch (e) {
      print('Error syncing data to Firestore: $e');
      rethrow;
    }
  }

  /// Check Firestore connection status
  Future<bool> checkConnection() async {
    try {
      await _firestore.collection('_health').doc('ping').set({
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Connection check failed: $e');
      return false;
    }
  }
}
