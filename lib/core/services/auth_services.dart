import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:expense_tracker/core/utils/database_helper.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  String _friendlyMessage(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'ERROR_NETWORK_REQUEST_FAILED':
        case 'network-request-failed':
          return 'No internet connection. Please check your network and try again.';
        case 'ERROR_USER_NOT_FOUND':
        case 'user-not-found':
          return 'No account found with this email address.';
        case 'ERROR_WRONG_PASSWORD':
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'ERROR_EMAIL_ALREADY_IN_USE':
        case 'email-already-in-use':
          return 'An account with this email already exists.';
        case 'ERROR_WEAK_PASSWORD':
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        case 'ERROR_INVALID_EMAIL':
        case 'invalid-email':
          return 'Invalid email address format.';
        case 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL':
        case 'account-exists-with-different-credential':
          return 'An account already exists with the same email but a different sign-in method.';
        case 'ERROR_TOO_MANY_REQUESTS':
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'ERROR_USER_DISABLED':
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'ERROR_INVALID_CREDENTIAL':
        case 'invalid-credential':
          return 'Invalid credentials. Please check your email and password.';
        default:
          return error.message ?? 'An unexpected error occurred.';
      }
    }
    if (error is GoogleSignInException) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return '';
      }
      if (error.code == GoogleSignInExceptionCode.clientConfigurationError) {
        return 'Google Sign-In is not configured properly. Please contact support.';
      }
      if (error.code == GoogleSignInExceptionCode.providerConfigurationError) {
        return 'Google Play Services needs to be updated.';
      }
      return error.description ?? 'Google Sign-In failed. Please try again.';
    }
    return error.toString();
  }

  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on SocketException {
      throw Exception(_friendlyMessage(SocketException('')));
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyMessage(e));
    } catch (e) {
      throw Exception(_friendlyMessage(e));
    }
  }

  Future<UserCredential?> loginWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on SocketException {
      throw Exception(_friendlyMessage(SocketException('')));
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyMessage(e));
    } catch (e) {
      throw Exception(_friendlyMessage(e));
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      throw Exception(_friendlyMessage(e));
    } on SocketException {
      throw Exception(
        'No internet connection. Please check your network and try again.',
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyMessage(e));
    } catch (e) {
      throw Exception(_friendlyMessage(e));
    }
  }

  Future<UserCredential?> signInWithApple() async {
    try {
      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleIdCredential.identityToken,
        accessToken: appleIdCredential.authorizationCode,
      );

      return await _auth.signInWithCredential(credential);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return null;
      }
      throw Exception(_friendlyMessage(e));
    } on SocketException {
      throw Exception(
        'No internet connection. Please check your network and try again.',
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyMessage(e));
    } catch (e) {
      throw Exception(_friendlyMessage(e));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on SocketException {
      throw Exception(_friendlyMessage(SocketException('')));
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyMessage(e));
    } catch (e) {
      throw Exception(_friendlyMessage(e));
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
    } on SocketException {
      throw Exception(
        'No internet connection. Please check your network and try again.',
      );
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> updatePersonalInfo({required String displayName}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');
    try {
      await user.updateDisplayName(displayName);
      await user.reload();
    } on SocketException {
      throw Exception(
        'No internet connection. Please check your network and try again.',
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyMessage(e));
    } catch (e) {
      throw Exception(_friendlyMessage(e));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');
    if (user.email == null) throw Exception('User email is null');

    try {
      final AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on SocketException {
      throw Exception(
        'No internet connection. Please check your network and try again.',
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyMessage(e));
    } catch (e) {
      throw Exception(_friendlyMessage(e));
    }
  }

  Future<void> signOut() async {
    try {
      await DatabaseHelper.instance.clearUserData();
    } catch (_) {}

    try {
      await _auth.signOut();
    } catch (_) {}
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  Stream<User?> get userStateChanges => _auth.authStateChanges();
}
