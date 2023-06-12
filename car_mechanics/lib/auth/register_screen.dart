// ignore_for_file: unused_field, prefer_final_fields, unused_local_variable, unused_element, use_build_context_synchronously

import 'package:car_mechanics/screen/car_mechanics_info.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

// import '../global/progress_dialog.dart';
import '../global/global.dart';
import 'forgot_password.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final confirmPasswordTextEditingController = TextEditingController();
  // final selectedRoleTextEditingController = TextEditingController();

  bool _passwordVisible = false;

  final _registerformKey = GlobalKey<FormState>();

  // showDialog(
  //   context: context,
  //   barrierDismissible: false,
  //   builder: (context) {
  //     return const ProgressDialog(
  //       message: "Processing, Please wait...",
  //     );
  //   },
  // );

  void _submited() async {
    if (_registerformKey.currentState!.validate()) {
      await firebaseAuth
          .createUserWithEmailAndPassword(
              email: emailTextEditingController.text.trim(),
              password: passwordTextEditingController.text.trim())
          .then((auth) async {
        currentUser = auth.user;

        if (currentUser != null) {
          Map userMap = {
            'id': currentUser!.uid,
            'name': nameTextEditingController.text.trim(),
            'email': emailTextEditingController.text.trim(),
            'phone': phoneTextEditingController.text.trim(),
            // 'role': selectedRoleTextEditingController.text.trim(),
          };

          DatabaseReference userRef =
              FirebaseDatabase.instance.ref().child("acim_mechanics");
          userRef.child(currentUser!.uid).set(userMap);
        }
        await Fluttertoast.showToast(msg: "Succefully register");
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CarMechanicsInfoScreen(),
            ));
      }).catchError((errorMessage) {
        Fluttertoast.showToast(msg: "Error occured: \n $errorMessage");
      });
    } else {
      Fluttertoast.showToast(msg: "Not all field a valid");
    }
  }

  String? selectRole;
  List<String> roles = ['Car_Mechanic', 'Car_Owner'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
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
                    "Registration Page",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Form(
                      key: _registerformKey,
                      child: Column(
                        children: [
                          TextFormField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                            ],
                            decoration: const InputDecoration(
                              hintText: "Name",
                              hintStyle: TextStyle(color: Colors.grey),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40)),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.black,
                              ),
                            ),
                            cursorColor: Colors.black,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return "Name can't be empty";
                              }
                              if (text.length < 2) {
                                return "Please enter a valid name";
                              }
                              if (text.length > 49) {
                                return "Name can't be more than 50";
                              }
                              return null;
                            },
                            onChanged: (value) => setState(() {
                              nameTextEditingController.text = value;
                            }),
                          ),
                          const SizedBox(height: 20),
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
                          IntlPhoneField(
                            keyboardType: TextInputType.phone,
                            showCountryFlag: false,
                            initialCountryCode: 'TZ',
                            decoration: const InputDecoration(
                              hintText: "Phone Number",
                              hintStyle: TextStyle(color: Colors.grey),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40)),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (value) => setState(() {
                              phoneTextEditingController.text =
                                  value.completeNumber;
                            }),
                          ),
                          TextFormField(
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
                          TextFormField(
                            obscureText: !_passwordVisible,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100),
                            ],
                            decoration: InputDecoration(
                              hintText: "Confirm password",
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
                                return "Confirm password can't be empty";
                              }
                              if (text != passwordTextEditingController.text) {
                                return "Password do not match";
                              }
                              if (text.length < 2) {
                                return "Please enter a valid Confirm password";
                              }
                              if (text.length > 99) {
                                return "Confirm password can't be more than 100";
                              }
                              return null;
                            },
                            onChanged: (value) => setState(() {
                              confirmPasswordTextEditingController.text = value;
                            }),
                          ),
                          //DropdownButtonFormField

                          const SizedBox(height: 20),
                          // DropdownButtonFormField(
                          //   value: selectRole,
                          //   decoration: const InputDecoration(
                          //     hintText: "Who are you...?",
                          //     hintStyle: TextStyle(color: Colors.grey),
                          //     filled: true,
                          //     border: OutlineInputBorder(
                          //       borderRadius:
                          //           BorderRadius.all(Radius.circular(40)),
                          //       borderSide: BorderSide.none,
                          //     ),
                          //     prefixIcon: Icon(
                          //       Icons.checklist_rtl,
                          //       color: Colors.black,
                          //     ),
                          //   ),
                          //   items: roles.map((role) {
                          //     return DropdownMenuItem(
                          //       value: role,
                          //       child: Text(role),
                          //     );
                          //   }).toList(),
                          //   onChanged: (value) {
                          //     setState(() {
                          //       selectRole = value;
                          //       selectedRoleTextEditingController.text =
                          //           value.toString();
                          //     });
                          //   },
                          //   validator: (select) {
                          //     if (select == null || select.isEmpty) {
                          //       return "Role can't be empty";
                          //     }
                          //     return null;
                          //   },
                          // ),
                          // const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              _submited();
                            },
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.grey,
                                backgroundColor: Colors.black,
                                minimumSize: const Size(double.infinity, 45),
                                elevation: 0,
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)))),
                            child: const Text(
                              "Register",
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
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("Already have an account"),
                              const SizedBox(width: 5),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Login",
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
