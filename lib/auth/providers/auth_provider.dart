import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../home/screens/helper_home/bottom_nav_screen.dart';

class AuthState {
  final bool isLoading;
  final User? user;

  AuthState({this.isLoading = false, this.user});
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> registerUser(
      String email, String password, BuildContext context) async {
    state = AuthState(isLoading: true);
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.sendEmailVerification();
      state = AuthState(isLoading: false, user: userCredential.user);
      return 'Verification';
    } on FirebaseAuthException catch (e) {
      state = AuthState(isLoading: false);
      if (e.code == 'email-already-in-use') {
        return 'Email in use';
      }
      return 'Registration error';
    }
  }

  Future<String?> loginUser(
      String email, String password, BuildContext context) async {
    state = AuthState(isLoading: true);
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null && userCredential.user!.emailVerified) {
        state = AuthState(isLoading: false, user: userCredential.user);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavScreen()),
          (route) => false,
        );
        return null;
      } else {
        state = AuthState(isLoading: false);
        _auth.signOut();
        return 'Unverified email';
      }
    } on FirebaseAuthException catch (e) {
      state = AuthState(isLoading: false);
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential' ||
          e.code == 'invalid-email' ||
          e.code == 'user-disabled') {
        return 'Invalid credentials';
      }
      return 'Login error';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = AuthState(isLoading: false, user: null);
  }

  /// Password reset method
  Future<String?> resetPassword(String email) async {
    try {
      // Attempt to send password reset email
      await _auth.sendPasswordResetEmail(email: email);
      return 'Password reset email sent';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'Email not registered';
      }
      return 'Failed to send reset email';
    }
  }
}

// Provider for auth state management
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

// Directly get the current user's ID from FirebaseAuth instance
final userIdProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// FirebaseStorage provider
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});
