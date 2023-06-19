// ignore_for_file: avoid_print

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../model/car_mechanic.dart';

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
          body: Column(
            children: [
              const SizedBox(height: 20),
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
              ListView(
                children: [
                  StreamBuilder<DatabaseEvent>(
                    stream: FirebaseDatabase.instance
                        .ref()
                        .child("acim_mechanics")
                        .orderByChild("newMechanicsServiceStatus")
                        .equalTo("Online")
                        .onValue,
                    builder: (BuildContext context,
                        AsyncSnapshot<DatabaseEvent> snapshot) {
                      if (snapshot.hasData) {
                        DataSnapshot data = snapshot.data!.snapshot;
                        if (data.value != null) {
                          Map<String, dynamic> carMechanicsData =
                              data.value as Map<String, dynamic>;

                          List<CarMechanic> onlineMechanics = carMechanicsData
                              .entries
                              .map((entry) => CarMechanic(
                                    key: entry.key,
                                    name: entry.value["name"],
                                    locationLatMechanics: double.parse(
                                        entry.value["latitude"].toString()),
                                    locationLngMechanics: double.parse(
                                        entry.value["longitude"].toString()),
                                  ))
                              .toList();

                          print(onlineMechanics);
                        }
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
