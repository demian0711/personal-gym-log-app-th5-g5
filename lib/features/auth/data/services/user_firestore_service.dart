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

  Future<void> ensureUserDocument({
    required String uid,
    String? username,
    required String email,
    required String displayName,
    String? photoUrl,
    required String authProvider,
  }) async {
    await upsertUserDocument(
      uid: uid,
      username: username,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      authProvider: authProvider,
    );

    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'user-doc-missing',
        message:
            'Không thể xác nhận dữ liệu user trên Firestore sau khi đăng ký.',
      );
    }
  }

  Future<bool> isUsernameUnique(String username) async {
    final query = await _usersCollection
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();
    return query.docs.isEmpty;
  }
}
