// ignore_for_file: avoid_print

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

class CarMechanicListScreen extends StatefulWidget {
  const CarMechanicListScreen({super.key});

  @override
  State<CarMechanicListScreen> createState() => _CarMechanicListScreenState();
}

class _CarMechanicListScreenState extends State<CarMechanicListScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text(
              "List Of Car Mechanics",
            ),
            elevation: 0,
          ),
          body: FirebaseAnimatedList(
            query: FirebaseDatabase.instance
                .ref()
                .child("acim_mechanics")
                .orderByChild("newMechanicsServiceStatus")
                .equalTo("Online"),
            itemBuilder: (BuildContext context, DataSnapshot snapshot,
                Animation<double> animation, int index) {
              Map carMechanicsSnapshot = snapshot.value as Map;
              // print(carMechanicsSnapshot);

              return ListTile(
                title: Text(carMechanicsSnapshot["name"]),
                subtitle: Text(
                  'Location: ${carMechanicsSnapshot['latitude']}, ${carMechanicsSnapshot['longitude']}',
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

              // Column(
              //   children: [
              //     Expanded(
              //       child: Column(
              //         children: [
              //           FirebaseAnimatedList(
              //             query: FirebaseDatabase.instance
              //                 .ref()
              //                 .child("acim_mechanics")
              //                 .orderByChild("newMechanicsServiceStatus")
              //                 .equalTo("Online"),
              //             itemBuilder: (BuildContext context, DataSnapshot snapshot,
              //                 Animation<double> animation, int index) {
              //               Map carMechanicsSnapshot = snapshot.value as Map;
              //               // print(carMechanicsSnapshot);

              //               return ListTile(
              //                 title: Text(carMechanicsSnapshot["name"]),
              //                 subtitle: Text(
              //                   'Location: ${carMechanicsSnapshot['latitude']}, ${carMechanicsSnapshot['longitude']}',
              //                 ),
              //               );
              //             },
              //           ),
              //           ElevatedButton(
              //             onPressed: () {
              //               Navigator.pop(context);
              //             },
              //             child: const Text("Select Car Mechanic"),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),

