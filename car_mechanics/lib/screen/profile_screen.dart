import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../global/global.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();

  DatabaseReference userRef =
      FirebaseDatabase.instance.ref().child("acim_user");

  Future<void> showUserNameDialogAlert(
      BuildContext context, String name) async {
    nameTextEditingController.text = name;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Profile"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: nameTextEditingController,
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                userRef.child(firebaseAuth.currentUser!.uid).update({
                  "name": nameTextEditingController.text.trim(),
                }).then((value) {
                  nameTextEditingController.clear();
                  Fluttertoast.showToast(
                      msg:
                          "Updated Succesfully. \n Reload the app to see the changes");
                }).catchError((errorMessage) {
                  Fluttertoast.showToast(
                      msg: "Error Occurred  \n $errorMessage");
                });
                Navigator.pop(context);
              },
              child: const Text(
                "Ok",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> showUserPhoneDialogAlert(
      BuildContext context, String phone) async {
    phoneTextEditingController.text = phone;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Profile"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: phoneTextEditingController,
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                userRef.child(firebaseAuth.currentUser!.uid).update({
                  "phone": phoneTextEditingController.text.trim(),
                }).then((value) {
                  nameTextEditingController.clear();
                  Fluttertoast.showToast(
                      msg:
                          "Updated Succesfully. \n Reload the app to see the changes");
                }).catchError((errorMessage) {
                  Fluttertoast.showToast(
                      msg: "Error Occurred  \n $errorMessage");
                });
                Navigator.pop(context);
              },
              child: const Text(
                "Ok",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
            ),
            title: const Text(
              "Profile Screen",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            elevation: 0.0,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 50),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(50),
                    decoration: const BoxDecoration(
                      color: Colors.lightBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${userModalCurrentInfo!.name}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showUserNameDialogAlert(
                              context, userModalCurrentInfo!.name!);
                        },
                        icon: const Icon(Icons.edit),
                      ),
                    ],
                  ),
                  const Divider(thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${userModalCurrentInfo!.email}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${userModalCurrentInfo!.phone}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showUserPhoneDialogAlert(
                              context, userModalCurrentInfo!.phone!);
                        },
                        icon: const Icon(Icons.edit),
                      ),
                    ],
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
