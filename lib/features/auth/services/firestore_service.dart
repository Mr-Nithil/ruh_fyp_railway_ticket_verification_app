import 'package:cloud_firestore/cloud_firestore.dart';
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
  }) async {
    try {
      final userModel = UserModel(
        uid: uid,
        name: name,
        email: email,
        nic: nic,
        checkerId: checkerId,
        createdAt: DateTime.now(),
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
}
