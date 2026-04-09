import 'package:cloud_firestore/cloud_firestore.dart';

class UserFirestoreService {
  final FirebaseFirestore _firestore;

  UserFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Future<void> upsertUserDocument({
    required String uid,
    String? username,
    required String email,
    required String displayName,
    String? photoUrl,
    required String authProvider,
  }) async {
    await _usersCollection.doc(uid).set({
      'uid': uid,
      'username': username,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'authProvider': authProvider,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<bool> isUsernameUnique(String username) async {
    final query = await _usersCollection
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();
    return query.docs.isEmpty;
  }
}
