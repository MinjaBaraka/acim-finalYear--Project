// ignore_for_file: avoid_print

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../model/car_mechanic.dart';

class CarMechanicListScreen extends StatefulWidget {
  const CarMechanicListScreen({super.key});

  @override
  State<CarMechanicListScreen> createState() => _CarMechanicListScreenState();
}

class _CarMechanicListScreenState extends State<CarMechanicListScreen> {
  void fetchOnlineMechanics() {
    DatabaseReference mechanicsRef =
        FirebaseDatabase.instance.ref().child("acim_mechanics");

    List<CarMechanic> onlineMechanics = [];

    mechanicsRef
        .orderByChild("newMechanicsServiceStatus")
        .equalTo("Online")
        .once()
        .then((carMechanicsSnapshot) {
      // print(carMechanicsSnapshot.snapshot.value);
      if (carMechanicsSnapshot.snapshot.value != null) {
        Map<dynamic, dynamic> carMechanicsData =
            carMechanicsSnapshot.snapshot as Map<dynamic, dynamic>;

        carMechanicsData.forEach((key, value) {
          CarMechanic carMechanic = CarMechanic(
            name: value["name"],
            locationLatMechanics: double.parse(value["latitude"].toString()),
            locationLngMechanics: double.parse(value["longitude"].toString()),
          );
          onlineMechanics.add(carMechanic);
        });
        print(onlineMechanics);
      }
      return onlineMechanics;
    });
  }

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
                Padding(
                  padding: const EdgeInsets.only(left: 80),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      fetchOnlineMechanics();
                    },
                    icon: const Icon(Icons.list),
                    label: const Text("List Of Car Mechanics"),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
