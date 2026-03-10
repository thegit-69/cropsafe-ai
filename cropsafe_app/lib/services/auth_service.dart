import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  /// Current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    // Open Google account selector
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    // User cancelled login
    if (googleUser == null) return null;

    // Get authentication tokens
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create Firebase credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase
    final result = await _auth.signInWithCredential(credential);

    // Create user profile in Firestore on first sign-in
    if (result.user != null) {
      _firestoreService.createUserProfile(result.user!);
    }

    return result;
  }

  /// Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
