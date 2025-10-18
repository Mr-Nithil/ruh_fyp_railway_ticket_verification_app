import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/auth/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  static const String usersCollection = 'users';

  // Create user document in Firestore
  Future<void> createUserDocument({
    required String uid,
    required String name,
    required String email,
    required String nic,
    required String checkerId,
    required String postgresId,
  }) async {
    try {
      final userModel = UserModel(
        uid: uid,
        name: name,
        email: email,
        nic: nic,
        checkerId: checkerId,
        createdAt: DateTime.now(),
        postgresId: postgresId,
      );

      await _firestore
          .collection(usersCollection)
          .doc(uid)
          .set(userModel.toMap());
    } catch (e) {
      throw Exception('Failed to create user document: $e');
    }
  }

  // Get user document from Firestore
  Future<UserModel?> getUserDocument(String uid) async {
    try {
      final docSnapshot = await _firestore
          .collection(usersCollection)
          .doc(uid)
          .get();

      if (docSnapshot.exists) {
        return UserModel.fromMap(docSnapshot.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user document: $e');
    }
  }

  // Update user document
  Future<void> updateUserDocument({
    required String uid,
    required Map<String, dynamic> updates,
  }) async {
    try {
      updates['updatedAt'] = DateTime.now().toIso8601String();

      await _firestore.collection(usersCollection).doc(uid).update(updates);
    } catch (e) {
      throw Exception('Failed to update user document: $e');
    }
  }

  // Delete user document
  Future<void> deleteUserDocument(String uid) async {
    try {
      await _firestore.collection(usersCollection).doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete user document: $e');
    }
  }

  // Check if user document exists
  Future<bool> userDocumentExists(String uid) async {
    try {
      final docSnapshot = await _firestore
          .collection(usersCollection)
          .doc(uid)
          .get();
      return docSnapshot.exists;
    } catch (e) {
      throw Exception('Failed to check user document: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.data();
    }
    return null;
  }
}
