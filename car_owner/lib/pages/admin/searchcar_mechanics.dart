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
  // void fetchOnlineMechanics() {
  //   DatabaseReference mechanicsRef =
  //       FirebaseDatabase.instance.ref().child("acim_mechanics");

  //   List<CarMechanic> onlineMechanics = [];

  //   mechanicsRef
  //       .orderByChild("newMechanicsServiceStatus")
  //       .equalTo("Online")
  //       .once()
  //       .then((carMechanicsSnapshot) {
  //     // print(carMechanicsSnapshot.snapshot.value);
  //     if (carMechanicsSnapshot.snapshot.value != null) {
  //       Map<String, dynamic> carMechanicsData =
  //           carMechanicsSnapshot as Map<String, dynamic>;

  //       carMechanicsData.forEach((key, value) {
  //         CarMechanic carMechanic = CarMechanic(
  //           key: '',
  //           name: value["name"],
  //           locationLatMechanics: double.parse(value["latitude"].toString()),
  //           locationLngMechanics: double.parse(value["longitude"].toString()),
  //         );
  //         onlineMechanics.add(carMechanic);
  //       });
  //       print(onlineMechanics);
  //     }
  //     return onlineMechanics;
  //   });
  // }

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
          // body: Column(
          //   children: [
          // const SizedBox(height: 20),
          // Padding(
          //   padding: const EdgeInsets.only(left: 80),
          //   child: ElevatedButton.icon(
          //     onPressed: () {
          //       fetchOnlineMechanics();
          //     },
          //     icon: const Icon(Icons.list),
          //     label: const Text("List Of Car Mechanics"),
          //   ),
          // ),
          //   ],
          // ),
          body: Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: FirebaseAnimatedList(
              query: FirebaseDatabase.instance
                  .ref()
                  .child("acim_mechanics")
                  .orderByChild("newMechanicsServiceStatus")
                  .equalTo("Online"),
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                Map carMechanicsSnapshot = snapshot.value as Map;
                print(carMechanicsSnapshot);
                // Process the snapshot data
                // Map<String, dynamic> mechanicsData = snapshot.value;

                return ListTile(
                  title: Text(carMechanicsSnapshot["name"]),
                  subtitle: Text(
                      'Location: ${carMechanicsSnapshot['latitude']}, ${carMechanicsSnapshot['longitude']}'),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
