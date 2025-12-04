import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'login_page.dart';
import 'email_verification_page.dart';
import '/home_page.dart';
import '/profile_creation_page.dart';

class WrapperPage extends StatelessWidget {
  const WrapperPage({super.key});

  // 🔍 Profile Check Logic
  Future<Widget> checkProfilePage(User user) async {
    final dbRef = FirebaseDatabase.instance.ref();
    final snapshot = await dbRef.child('Users/${user.uid}').get();

    if (snapshot.exists) {
      return const HomePage(); // ✅ Profile exists
    } else {
      return const ProfileCreationPage(); // ❌ Go to profile creation
    }
  }

  // ⏳ Reusable Loading Widget
  Widget buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 11, 96, 175),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return buildLoadingScreen(); // ⏳ Waiting for auth state
        }

        final user = authSnapshot.data;

        if (user == null) {
          return const LoginPage(); // 🔐 Not logged in
        }

        if (!user.emailVerified) {
          return const EmailVerificationPage(); // 📧 Email not verified
        }

        // ✅ Email verified, check if profile is created
        return FutureBuilder<Widget>(
          future: checkProfilePage(user),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return buildLoadingScreen(); // ⏳ Checking profile
            }

            return profileSnapshot.data ?? const LoginPage(); // 🚀 Navigate
          },
        );
      },
    );
  }
}
