// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:car_onwer/global/global.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

import '../../model/carmechanics_nearby.dart';

class CarMechanicListScreen extends StatefulWidget {
  const CarMechanicListScreen({Key? key}) : super(key: key);

  @override
  _CarMechanicListScreenState createState() => _CarMechanicListScreenState();
}

class _CarMechanicListScreenState extends State<CarMechanicListScreen> {
  List<CarMechanic> carMechanics = [];

  fetchCarMechanics() {
    DatabaseReference mechanicsRef = FirebaseDatabase.instance
        .ref()
        .child("acim_mechanics")
        .child(currentUser!.uid);

    mechanicsRef.once().then((carMechanicsSnapShot) {
      if (carMechanicsSnapShot.snapshot.value != null) {
        carMechanicsCurrentInfo =
            CarMechanic.fromSnapshot(carMechanicsSnapShot.snapshot);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Nearby Car Mechanics'),
          ),
          body: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
                child: ElevatedButton(
                  onPressed: () {
                    // fetchCarMechanics();
                    print(fetchCarMechanics());
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                    elevation: 0,
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("display car Mechanics"),
                ),
              ),
            ],
          )),
    );
  }
}
