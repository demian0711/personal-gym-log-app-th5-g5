import '../../domain/repositories/profile_repository.dart';
import '../models/user_model.dart';
import '../services/profile_firestore_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileFirestoreService _service;

  ProfileRepositoryImpl(this._service);

  @override
  Future<UserModel> fetchOrCreateProfile({
    required String userId,
    required String email,
    required String fallbackDisplayName,
    String? photoUrl,
  }) async {
    final existing = await _service.fetchUser(userId);
    if (existing != null) {
      return existing;
    }

    final defaultUser = UserModel(
      userId: userId,
      email: email,
      displayName: fallbackDisplayName.trim().isNotEmpty
          ? fallbackDisplayName.trim()
          : 'User',
      photoUrl: photoUrl,
      goal: 'duy trì',
      unit: 'kg',
      weeklyTarget: 3,
      targetWeight: null,
    );

    await _service.createDefaultUser(defaultUser);
    return defaultUser;
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    await _service.updateUser(user);
    return user;
  }
}
