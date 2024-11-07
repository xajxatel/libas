import 'package:closetly/auth/screens/landing.dart';
import 'package:closetly/home/screens/helper_home/bottom_nav_screen.dart';
import 'package:closetly/home/widgets/loading_circle.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance
          .authStateChanges(), // Listen to real-time auth state
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null) {
            return const BottomNavScreen(); // User is logged in, go to Home screen.
          } else {
            return const LandingScreen(); // User is not logged in, go to Landing screen.
          }
        }
        // Show a loading screen while checking authentication status.
        return const Scaffold(
          body: Center(child: LoadingCircle()),
        );
      },
    );
  }
}
