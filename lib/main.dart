import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:latecommer/authantication/signup_page.dart';
import 'package:latecommer/authantication/login_page.dart';
import 'package:latecommer/authantication/email_verification_page.dart';
import 'package:latecommer/authantication/wrapper_page.dart';
import 'package:latecommer/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyA2carq62EqNPtRkrg6FZDedDQ7PDTSBbQ",
        authDomain: "latecommer-34076.firebaseapp.com",
        databaseURL: "https://latecommer-34076-default-rtdb.firebaseio.com",
        projectId: "latecommer-34076",
        storageBucket: "latecommer-34076.appspot.com",
        messagingSenderId: "240509982911",
        appId: "1:240509982911:web:2a16c2992363b4ccbf8e0a",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Latecomer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // 👈 Show Splash first
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/verify': (context) => const EmailVerificationPage(),
        '/home': (context) => const WrapperPage(),
      },
    );
  }
}
