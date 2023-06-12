import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../global/global.dart';
import 'login_screen.dart';

class SignoutScreen extends StatelessWidget {
  const SignoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            firebaseAuth.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              elevation: 5.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: GoogleFonts.aboreto(
                fontSize: 25,
              )),
          child: const Text("Logout"),
        ),
      ),
    );
  }
}
