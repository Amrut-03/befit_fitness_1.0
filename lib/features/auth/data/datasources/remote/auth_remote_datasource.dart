import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/features/auth/data/models/user_model.dart';
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

  Future<void> deleteAccount() async {
    final user = firebaseAuth.currentUser;

    if (user != null) {
      await user.delete();
    }
  }

  Future<void> saveUserProfile(UserModel user) async {
    /// Firestore save logic later
  }
}
