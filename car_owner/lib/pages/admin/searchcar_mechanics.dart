import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../global/global.dart';
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

    mechanicsRef
        .orderByChild("newMechanicsServiceStatus")
        .equalTo("Online")
        .once()
        .then((DataSnapshot snapshot) {
          if (snapshot.value != null) {
            Map<dynamic, dynamic> dataMap =
                snapshot.value as Map<dynamic, dynamic>;

            // Iterate over the mechanics data map and extract the required information
            List<CarMechanic> onlineMechanics = [];
            dataMap.forEach((key, value) {
              CarMechanic mechanic = CarMechanic(
                name: value['name'],
                locationLatMechanics:
                    double.parse(value['latitude'].toString()),
                locationLngMechanics:
                    double.parse(value['longitude'].toString()),
              );
              onlineMechanics.add(mechanic);
            });

            // Display the list of online mechanics on the car owner's screen
            setState(() {
              onlineMechanicsList = onlineMechanics;
            });
          } else {
            // Handle the case when there are no online mechanics
            setState(() {
              onlineMechanicsList = [];
            });
          }
        } as FutureOr Function(DatabaseEvent value));
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
          // body:
        ),
      ),
    );
  }
}
