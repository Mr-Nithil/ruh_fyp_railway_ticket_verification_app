import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Constructor to configure Firebase Auth settings
  AuthRepository() {
    _configureFirebaseAuth();
  }

  // Configure Firebase Auth for better development experience
  void _configureFirebaseAuth() {
    // Set persistence for web
    // _firebaseAuth.setPersistence(Persistence.LOCAL);

    // For development/testing: Disable app verification (Android only)
    // Note: This should only be used in development
    _firebaseAuth.setSettings(
      appVerificationDisabledForTesting: true,
      forceRecaptchaFlow: false,
    );
  }

  bool isAuthorized() {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found with this email.');
        case 'wrong-password':
          throw Exception('Wrong password provided.');
        case 'invalid-email':
          throw Exception('Invalid email address.');
        case 'user-disabled':
          throw Exception('This user account has been disabled.');
        case 'network-request-failed':
          throw Exception('Network error. Please check your connection.');
        default:
          throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> signup(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('An account already exists with this email.');
        case 'invalid-email':
          throw Exception('Invalid email address.');
        case 'operation-not-allowed':
          throw Exception('Email/password accounts are not enabled.');
        case 'weak-password':
          throw Exception(
            'Password is too weak. Please use a stronger password.',
          );
        case 'network-request-failed':
          throw Exception('Network error. Please check your connection.');
        default:
          throw Exception('Registration failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
