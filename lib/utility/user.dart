import 'package:firebase_auth/firebase_auth.dart';

class UserAuth {
  static Future<bool> signupWithEmailPass(
      {required String email, required String password}) async {
    try {
      UserCredential cred =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Optional: send verification email
      await cred.user!.sendEmailVerification();

      // Get User ID (for saving profile later)
      String userId = cred.user!.uid;

      // TODO: Save additional profile data using userId

      return true;
    } catch (e) {
      print("Signup error: $e");
      return false;
    }
  }
}
