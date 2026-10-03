import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static User? get currentUser => FirebaseAuth.instance.currentUser;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential?> signInWithGoogle() async {
    final account = await GoogleSignIn().signIn();
    if (account == null) return null;

    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  static Future<UserCredential> signInEmail(
      String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<UserCredential> registerEmail(
      String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> signOut() => _auth.signOut();
}
