import 'package:car_mechanics/splashScreen/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../auth/forgot_password.dart';
import '../auth/login_screen.dart';
import '../global/global.dart';

class CarMechanicsInfoScreen extends StatefulWidget {
  const CarMechanicsInfoScreen({super.key});

  @override
  State<CarMechanicsInfoScreen> createState() => _CarMechanicsInfoScreenState();
}

class _CarMechanicsInfoScreenState extends State<CarMechanicsInfoScreen> {
  final carModelTextEditingController = TextEditingController();
  final carNumberTextEditingController = TextEditingController();
  final carColorTextEditingController = TextEditingController();

  List<String> carTypes = ["Car", "CNG", "Bike"];
  String? selectedCarType;

  final _formKey = GlobalKey<FormState>();

  _submited() {
    if (_formKey.currentState!.validate()) {
      Map mechanicsCarInfoMap = {
        "Car_Model": carModelTextEditingController.text.trim(),
        "Car_Number": carNumberTextEditingController.text.trim(),
        "Car_Color": carColorTextEditingController.text.trim(),
      };

      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child("acim_mechanics");
      userRef
          .child(currentUser!.uid)
          .child("Car_mechanics_details")
          .set(mechanicsCarInfoMap);

      Fluttertoast.showToast(
          msg: "Car mechanics details has been saved. Congratulations");

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SplashScreen(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(10),
            children: [
              Column(
                children: [
                  const Text(
                    "Select Car Your professional Mechanics",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Add Car Details",
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                            ],
                            decoration: const InputDecoration(
                              hintText: "Car Model",
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
                                return "Car Model can't be empty";
                              }
                              if (text.length < 2) {
                                return "Please enter a valid name";
                              }
                              if (text.length > 49) {
                                return "Car Model can't be more than 50";
                              }
                              return null;
                            },
                            onChanged: (value) => setState(() {
                              carModelTextEditingController.text = value;
                            }),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                            ],
                            decoration: const InputDecoration(
                              hintText: "Car Number",
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
                                return "Car Number can't be empty";
                              }
                              if (text.length < 2) {
                                return "Please enter a valid name";
                              }
                              if (text.length > 49) {
                                return "Car Number can't be more than 50";
                              }
                              return null;
                            },
                            onChanged: (value) => setState(() {
                              carNumberTextEditingController.text = value;
                            }),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                            ],
                            decoration: const InputDecoration(
                              hintText: "Car Color",
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
                                return "Car Color can't be empty";
                              }
                              if (text.length < 2) {
                                return "Please enter a valid name";
                              }
                              if (text.length > 49) {
                                return "Car Color can't be more than 50";
                              }
                              return null;
                            },
                            onChanged: (value) => setState(() {
                              carColorTextEditingController.text = value;
                            }),
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField(
                            decoration: const InputDecoration(
                              hintText: "Please Choose Car Type",
                              prefixIcon: Icon(
                                Icons.car_crash,
                                color: Colors.black,
                              ),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(40),
                                ),
                                borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                            ),
                            items: carTypes.map((car) {
                              return DropdownMenuItem(
                                value: car,
                                child: Text(
                                  car,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (newvalue) {
                              setState(() {
                                selectedCarType = newvalue.toString();
                              });
                            },
                          ),
                          const SizedBox(height: 20),
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
                              "Confirm details",
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
