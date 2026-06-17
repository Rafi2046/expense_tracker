import 'package:firebase_auth/firebase_auth.dart';
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
      // Note: If the user cancels the popup, this throws an exception rather than returning null.
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // 4. Get the ID token (this property is now synchronous)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 5. Explicitly request authorization scopes to get the access token
      final clientAuth = await googleUser.authorizationClient.authorizeScopes([
        'email',
        'profile',
      ]);

      // 6. Build the Firebase credential using both tokens
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: clientAuth.accessToken,
      );

      // 7. Sign in to Firebase
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

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Stream<User?> get userStateChanges => _auth.authStateChanges();
}