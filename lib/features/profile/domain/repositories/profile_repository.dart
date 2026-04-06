import '../../data/models/user_model.dart';

/// Abstraction cho profile repository.
abstract class ProfileRepository {
  Future<UserModel> fetchOrCreateProfile({
    required String userId,
    required String email,
    required String fallbackDisplayName,
    String? photoUrl,
  });

  Future<UserModel> updateProfile(UserModel user);
}
