import '../../data/models/user_profile_model.dart';

/// Abstract interface for user data operations
abstract class IUserRepository {
  /// Check if user has completed profile
  Future<bool> hasUserProfile(String uid);

  /// Get user profile
  Future<UserProfile?> getUserProfile(String uid);

  /// Watch user profile for real-time updates
  Stream<UserProfile?> watchUserProfile(String uid);

  /// Create or update user profile
  Future<void> saveUserProfile(UserProfile profile);

  /// Update user profile with full object
  Future<void> updateUserProfile(UserProfile profile);

  /// Update specific fields of user profile
  Future<void> updateUserProfileFields(String uid, Map<String, dynamic> data);

  /// Delete user profile
  Future<void> deleteUserProfile(String uid);
}
