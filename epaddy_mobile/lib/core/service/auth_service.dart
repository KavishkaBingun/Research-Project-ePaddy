import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 🔹 Sign Up with Email & Password
  Future<User?> signUpWithEmail(String email, String password, String fullName, String nic) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Save user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'fullName': fullName,
        'nic': nic,
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    } catch (e) {
      throw Exception("An unexpected error occurred: $e");
    }
  }

  // 🔹 Login with Email & Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    } catch (e) {
      throw Exception("An unexpected error occurred: $e");
    }
  }

  // 🔹 Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Check if user exists in Firestore
      final userDoc = _firestore.collection('users').doc(userCredential.user!.uid);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        // Save user data if new
        await userDoc.set({
          'fullName': googleUser.displayName ?? 'No Name',
          'email': googleUser.email,
          'nic': 'Not set',
          'provider': 'google',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else {
        await userDoc.update({'lastLogin': FieldValue.serverTimestamp()});
      }

      return userCredential.user;
    } catch (e) {
      throw Exception("Google Sign-In failed: $e");
    }
  }

  // 🔹 Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw Exception("Error signing out: $e");
    }
  }

  // 🔹 Password Reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      throw Exception("Failed to send password reset email.");
    }
  }

  // 🔹 Handle Firebase Auth Errors
  String _handleAuthError(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'Invalid email format.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
