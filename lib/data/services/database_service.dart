import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile_model.dart';
import '../models/exercise_model.dart';
import '../models/workout_session_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _exercisesCollection => _firestore.collection('exercises_library');
  CollectionReference get _historyCollection => _firestore.collection('history');

  // --- User Profile ---

  Future<void> createUserProfile(UserProfile profile) async {
    await _usersCollection.doc(profile.uid).set(profile.toMap());
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    DocumentSnapshot doc = await _usersCollection.doc(uid).get();
    if (doc.exists) {
      return UserProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    await _usersCollection.doc(profile.uid).update(profile.toMap());
  }

  // --- Exercises ---

  Future<List<Exercise>> getExercises() async {
    QuerySnapshot snapshot = await _exercisesCollection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Exercise.fromMap(data);
    }).toList();
  }
  
  // Method to seed or add an exercise (helper)
  Future<void> addExercise(Exercise exercise) async {
    await _exercisesCollection.doc(exercise.id).set(exercise.toMap());
  }

  // --- History / Workout Sessions ---

  Future<void> saveWorkoutSession(WorkoutSession session) async {
    // If id is empty or new, let Firestore generate one, but model assumes id.
    // Usually we generate ID first or let firestore do it.
    if (session.id.isEmpty) {
       await _historyCollection.add(session.toMap());
    } else {
       await _historyCollection.doc(session.id).set(session.toMap());
    }
  }

  Future<List<WorkoutSession>> getUserHistory(String uid) async {
    QuerySnapshot snapshot = await _historyCollection
        .where('user_id', isEqualTo: uid)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return WorkoutSession.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }
}
