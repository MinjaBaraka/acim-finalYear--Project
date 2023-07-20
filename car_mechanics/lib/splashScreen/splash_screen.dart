// ignore_for_file: await_only_futures, use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';

import '../auth/login_screen.dart';
import '../global/global.dart';
import '../requestMethod/request_method.dart';
import '../screen/main_admin_screen.dart';
// import '../auth/signout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () async {
      if (firebaseAuth.currentUser != null) {
        firebaseAuth.currentUser != null
            ? RequestMethod.readCurrentOnlineUserInfo(context)
            : null;

        // RequestMethod.readCurrentOnlineUserInfo(context);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            // builder: (context) => const SignoutScreen(),
            builder: (context) => const MechanicScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: const SafeArea(
        child: Scaffold(
          body: Center(
            child: Text(
              "Mechanics Flutter Developer",
              style: TextStyle(
                fontSize: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
