import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Use the singleton instance instead of a constructor
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<UserCredential?> loginWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 2. Mandatory initialization step for v7+
      await _googleSignIn.initialize();

      // 3. Trigger the new authentication flow (replaces signIn)
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // 4. Get the ID token (synchronous property in v7)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 5. Build the Firebase credential using the ID token
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // 6. Sign in to Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      // Catches user cancellations or network errors
      throw Exception(e.toString());
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<String> uploadProfileImage(File file) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('profile.jpg');

      final UploadTask uploadTask = storageRef.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // Ignore or log error
    }
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignore error since user might have logged in via email/password
    }
  }

  Stream<User?> get userStateChanges => _auth.authStateChanges();
}