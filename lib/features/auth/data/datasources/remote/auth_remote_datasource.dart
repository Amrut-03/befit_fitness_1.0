import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/features/auth/data/models/user_model.dart';
import 'package:fitness_app/features/auth/domain/exceptions/account_deletion_exception.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSource({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  Future<UserModel?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await firebaseAuth.signInWithCredential(credential);

    final user = userCredential.user;

    if (user == null) return null;

    return UserModel.fromFirebaseUser(user, isGuest: false);
  }

  Future<UserModel?> signInAsGuest() async {
    final userCredential = await firebaseAuth.signInAnonymously();

    final user = userCredential.user;

    if (user == null) return null;

    return UserModel.fromFirebaseUser(user, isGuest: true);
  }

  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;

    print(user);

    if (user == null) return null;

    return UserModel.fromFirebaseUser(user, isGuest: user.isAnonymous);
  }

  Stream<UserModel?> watchAuthState() {
    return firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;

      return UserModel.fromFirebaseUser(user, isGuest: user.isAnonymous);
    });
  }

  Future<void> signOut() async {
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
  }

  String? get currentUid => firebaseAuth.currentUser?.uid;

  /// Firebase only lets a user delete their account with a recent sign-in.
  /// For Google users, get a fresh credential up front so `user.delete()`
  /// doesn't fail with `requires-recent-login` after the data is already gone.
  /// Anonymous users can't re-authenticate, so this does nothing for them.
  Future<void> reauthenticate() async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw const AccountDeletionException(AccountDeletionFailure.notSignedIn);
    }

    final usesGoogle = user.providerData.any(
      (p) => p.providerId == GoogleAuthProvider.PROVIDER_ID,
    );
    if (user.isAnonymous || !usesGoogle) return;

    final googleUser =
        await googleSignIn.signInSilently() ?? await googleSignIn.signIn();
    if (googleUser == null) {
      throw const AccountDeletionException(AccountDeletionFailure.cancelled);
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await user.reauthenticateWithCredential(credential);
  }

  /// Deletes the Firebase Auth user and revokes the app's Google grant.
  Future<void> deleteCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return;

    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      // A stale anonymous session can't be re-authenticated. Its data is
      // already deleted, so signing out leaves an empty, unreachable account.
      if (e.code == 'requires-recent-login' && user.isAnonymous) {
        await firebaseAuth.signOut();
        return;
      }
      rethrow;
    }

    try {
      await googleSignIn.disconnect();
    } catch (_) {
      // Not signed in with Google, or already disconnected.
      try {
        await googleSignIn.signOut();
      } catch (_) {}
    }
  }
}
