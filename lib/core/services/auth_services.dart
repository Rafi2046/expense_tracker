import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:expense_tracker/core/utils/database_helper.dart';
import 'package:expense_tracker/core/utils/profile_photo_resolver.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:expense_tracker/features/tours/utils/tour_image_codec.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// True while Google/Apple auth UI is open (app may pause/resume).
  /// AppLockManager must ignore lifecycle lock during this window.
  static bool oauthInProgress = false;

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

  bool _googleInitialized = false;

  Future<UserCredential?> signInWithGoogle() async {
    AuthService.oauthInProgress = true;
    try {
      // Sign out first to force account picker to show (avoids stale session)
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      // initialize() only needs to be called once per app session.
      // Android: SHA-1 + google-services.json (no clientId).
      // iOS: native iOS OAuth clientId + web serverClientId for Firebase idToken.
      if (!_googleInitialized) {
        if (Platform.isIOS) {
          await _googleSignIn.initialize(
            clientId:
                '1018341294472-fimc4j5cm1cpvdfil0c7gujv88mm2e1e.apps.googleusercontent.com',
            serverClientId:
                '1018341294472-on5co00vr8j4qadbqm3i70isbbfp7r26.apps.googleusercontent.com',
          );
        } else if (Platform.isAndroid) {
          await _googleSignIn.initialize();
        } else {
          await _googleSignIn.initialize(
            clientId:
                '1018341294472-on5co00vr8j4qadbqm3i70isbbfp7r26.apps.googleusercontent.com',
          );
        }
        _googleInitialized = true;
      }

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
      _googleInitialized = false; // reset so next attempt re-initializes
      throw Exception(_friendlyMessage(e));
    } on SocketException {
      throw Exception(
        'No internet connection. Please check your network and try again.',
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        throw Exception(
          'Google Sign-In failed. Please make sure Google Sign-In is enabled in Firebase Console and the SHA-1 fingerprint is registered.',
        );
      }
      throw Exception(_friendlyMessage(e));
    } catch (e) {
      _googleInitialized = false; // reset on unknown errors
      throw Exception(_friendlyMessage(e));
    } finally {
      AuthService.oauthInProgress = false;
    }
  }

  Future<UserCredential?> signInWithApple() async {
    AuthService.oauthInProgress = true;
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

      final userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        if (user.displayName == null || user.displayName!.trim().isEmpty) {
          final givenName = appleIdCredential.givenName;
          final familyName = appleIdCredential.familyName;
          final fullName = [givenName, familyName].where((n) => n != null).join(' ');
          if (fullName.isNotEmpty) {
            await user.updateDisplayName(fullName);
          } else if (user.email != null && user.email!.isNotEmpty) {
            await user.updateDisplayName(user.email!.split('@').first);
          }
        }
      }

      return userCredential;
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
    } finally {
      AuthService.oauthInProgress = false;
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

  /// Compresses [file] and syncs via Firestore (no Firebase Storage).
  ///
  /// Storage kept returning `object-not-found` for profile paths even when
  /// tour_covers worked from other code paths — Firestore already syncs
  /// reliably for this account, so profile photos use `b64:` there.
  Future<String> uploadProfileImage(File file) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      if (!await file.exists()) {
        throw Exception('Selected image file is missing');
      }

      final encoded = await TourImageCodec.encodeFile(file.path, isCover: false);
      if (encoded == null || encoded.isEmpty) {
        throw Exception('Could not compress profile photo');
      }

      // Soft size guard — Firestore doc limit is 1 MiB.
      if (encoded.length > 900 * 1024) {
        throw Exception('Profile photo is too large after compression');
      }

      await persistProfilePhotoUrl(encoded);
      return encoded;
    } on SocketException {
      throw Exception(
        'No internet connection. Please check your network and try again.',
      );
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Writes photo to Auth (https only) + Firestore settings/profile + prefs.
  Future<void> persistProfilePhotoUrl(String photoUrl) async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (!ProfilePhotoResolver.isCloudValue(photoUrl)) return;

    // Firebase Auth photoURL only accepts http(s) URLs.
    if (TourImageCodec.isNetwork(photoUrl)) {
      try {
        await user.updatePhotoURL(photoUrl);
      } catch (e) {
        debugPrint('AuthService.persistProfilePhotoUrl Auth update failed: $e');
      }
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('profile')
          .set(
        {
          'photoUrl': photoUrl,
          'photoUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('AuthService.persistProfilePhotoUrl Firestore failed: $e');
      rethrow;
    }

    await SharedPrefsHelper.setString(
      'local_profile_photo_${user.uid}',
      photoUrl,
    );
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
      final user = _auth.currentUser;
      if (user != null) {
        await SharedPrefsHelper.remove('has_synced_for_user_${user.uid}');
      }
    } catch (_) {}

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

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');
    try {
      await user.sendEmailVerification();
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

  Stream<User?> get userStateChanges => _auth.authStateChanges();
}
