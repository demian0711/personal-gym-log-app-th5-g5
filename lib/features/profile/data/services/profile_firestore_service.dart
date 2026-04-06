import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

/// Service làm việc trực tiếp với Firebase Firestore cho module Profile.
class ProfileFirestoreService {
  final FirebaseFirestore _firestore;

  ProfileFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Future<UserModel?> fetchUser(String userId) async {
    final document = await _usersCollection.doc(userId).get();
    if (!document.exists) {
      return null;
    }
    return UserModel.fromFirestore(document);
  }

  Future<void> createDefaultUser(UserModel user) async {
    await _usersCollection.doc(user.userId).set(user.toMap());
  }

  Future<void> updateUser(UserModel user) async {
    await _usersCollection
        .doc(user.userId)
        .set(user.toMap(), SetOptions(merge: true));
  }
}
