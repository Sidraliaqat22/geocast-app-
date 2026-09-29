import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService {

  // --- LOGIN FUNCTION (One-Tap Login) ---
  Future<void> loginWithGoogle(BuildContext context, Widget nextPage) async {
    try {
      // 1. SIGN OUT WALI LINE HATA DI HAI:
      // Ab ye baar baar email nahi poochega agar session mojud hai.

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': user.displayName,
          'email': user.email,
          'profilePic': user.photoURL,
          'uid': user.uid,
          'lastLogin': DateTime.now(),
        }, SetOptions(merge: true));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextPage),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed: $e")),
      );
    }
  }

  // --- LOGOUT FUNCTION ---
  // Is function ke andar 'disconnect' mojud hai taake logout ke BAAD hi email pooche.
  Future<void> logout(BuildContext context, Widget loginScreen) async {
    try {
      // Google ka session bilkul khatam kar dega
      await GoogleSignIn().disconnect();
      await FirebaseAuth.instance.signOut();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => loginScreen),
      );
    } catch (e) {
      print("Logout Error: $e");
    }
  }
}