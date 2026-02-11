import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/i_user_repository.dart';
import '../models/user_profile_model.dart';

/// Repository for user data operations
class UserRepository implements IUserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Check if user has completed profile
  @override
  Future<bool> hasUserProfile(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get user profile
  @override
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Watch user profile for real-time updates
  @override
  Stream<UserProfile?> watchUserProfile(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }

  /// Create or update user profile
  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    await _usersCollection.doc(profile.uid).set(
      profile.toMap(),
      SetOptions(merge: true),
    );
  }

  /// Update user profile with full object
  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    await _usersCollection.doc(profile.uid).update(
      profile.copyWith(updatedAt: DateTime.now()).toMap(),
    );
  }

  /// Update specific fields of user profile
  @override
  Future<void> updateUserProfileFields(String uid, Map<String, dynamic> data) async {
    data['updated_at'] = Timestamp.now();
    await _usersCollection.doc(uid).update(data);
  }

  /// Delete user profile
  @override
  Future<void> deleteUserProfile(String uid) async {
    await _usersCollection.doc(uid).delete();
  }
}
