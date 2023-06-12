// ignore_for_file: use_build_context_synchronously

import 'package:car_mechanics/splashScreen/splash_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';
import '../screen/main_admin_screen.dart';
import 'forgot_password.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();

  bool _passwordVisible = false;

  final _loginformKey = GlobalKey<FormState>();

  // ignore: unused_element
  void _submitted() async {
    if (_loginformKey.currentState!.validate()) {
      await firebaseAuth
          .signInWithEmailAndPassword(
              email: emailTextEditingController.text.trim(),
              password: passwordTextEditingController.text.trim())
          .then((auth) async {
// Check if the logged-in user has the role of a car mechanic
        DatabaseReference userRef =
            FirebaseDatabase.instance.ref().child("acim_mechanics");
        userRef.child(firebaseAuth.currentUser!.uid).once().then((value) async {
          final snap = value.snapshot;
          if (snap.value != null) {
            currentUser = auth.user;
            await Fluttertoast.showToast(msg: "Successfully logged in");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MechanicScreen(),
              ),
            );
          } else {
            await Fluttertoast.showToast(
                msg: "No record exist with this email");
            firebaseAuth.signOut();
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SplashScreen(),
                ));
          }
        });
      }).catchError((errorMessage) {
        Fluttertoast.showToast(msg: "Error occured: \n $errorMessage");
      });
    } else {
      Fluttertoast.showToast(msg: "Not all field a valid");
    }
  }

  // void _submitted() async {
  //   if (_loginformKey.currentState!.validate()) {
  //     await firebaseAuth
  //         .signInWithEmailAndPassword(
  //             email: emailTextEditingController.text.trim(),
  //             password: passwordTextEditingController.text.trim())
  //         .then((auth) async {
  //       DatabaseReference userRef =
  //           FirebaseDatabase.instance.ref().child("acim_user");
  //       userRef.child(firebaseAuth.currentUser!.uid).once().then((value) async {
  //         final snap = value.snapshot;
  //         if (snap.value != null) {
  //           Map<String, dynamic> userMap = snap.value as Map<String, dynamic>;
  //           // Check if the logged-in user has the role of a car mechanic
  //           if (userMap['role'] == 'Car_Owner') {
  //             currentUser = auth.user;
  //             await Fluttertoast.showToast(msg: "Successfully logged in");
  //             Navigator.pushReplacement(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => const AdminScreen(),
  //               ),
  //             );
  //           } else {
  //             await Fluttertoast.showToast(
  //                 msg: "You are not authorized to access this app");
  //             firebaseAuth.signOut();
  //             Navigator.pushReplacement(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => const SplashScreen(),
  //               ),
  //             );
  //           }
  //         } else {
  //           await Fluttertoast.showToast(
  //               msg: "No record exists with this email");
  //           firebaseAuth.signOut();
  //           Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => const SplashScreen(),
  //             ),
  //           );
  //         }
  //       });
  //     }).catchError((errorMessage) {
  //       Fluttertoast.showToast(msg: "Error occurred: \n $errorMessage");
  //     });
  //   } else {
  //     Fluttertoast.showToast(msg: "Not all fields are valid");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          FocusScope.of(context).unfocus();
        });
      },
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    "Login Page",
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Form(
                      key: _loginformKey,
                      child: Column(
                        children: [
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100),
                            ],
                            decoration: const InputDecoration(
                              hintText: "Email",
                              hintStyle: TextStyle(color: Colors.grey),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40)),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.black,
                              ),
                            ),
                            cursorColor: Colors.black,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return "Email can't be empty";
                              }
                              if (EmailValidator.validate(text) == true) {
                                return null;
                              }
                              if (!RegExp(
                                      r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                                  .hasMatch(text)) {
                                return 'Please enter a valid email';
                              }
                              // if (text.length < 2) {
                              //   return "Please enter a valid email";
                              // }
                              if (text.length > 99) {
                                return "Email can't be more than 100";
                              }
                              return null;
                            },
                            onChanged: (value) => setState(() {
                              emailTextEditingController.text = value;
                            }),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: !_passwordVisible,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100),
                            ],
                            decoration: InputDecoration(
                              hintText: "Password",
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40)),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Colors.black,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                            ),
                            cursorColor: Colors.black,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return "Password can't be empty";
                              }

                              if (text.length < 2) {
                                return "Please enter a valid password";
                              }
                              if (text.length > 99) {
                                return "Password can't be more than 100";
                              }
                              return null;
                            },
                            onChanged: (value) => setState(() {
                              passwordTextEditingController.text = value;
                            }),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              _submitted();
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.grey,
                              backgroundColor: Colors.black,
                              minimumSize: const Size(double.infinity, 45),
                              elevation: 0,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                              ),
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Forgot Password",
                              style: TextStyle(
                                color: Colors.blue,
                                // fontSize: 30,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("I don't have an account?"),
                              const SizedBox(width: 5),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "register",
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
