// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

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

  @override
  void initState() {
    super.initState();
    fetchNearbyCarMechanics();
  }

  Future<void> fetchNearbyCarMechanics() async {
    // Get the current user's location
    Position position = await getCurrentUserLocation();

    // Fetch car mechanics from Firebase database
    DatabaseReference mechanicsRef =
        FirebaseDatabase.instance.ref().child('car_mechanics');

    mechanicsRef.once().then((DataSnapshot snapshot) {
          if (snapshot.value != null) {
            Map<dynamic, dynamic> dataMap =
                snapshot.value as Map<dynamic, dynamic>;

            List<CarMechanic> nearbyMechanics = [];

            dataMap.forEach((key, value) {
              double latitude = double.parse(value['latitude'].toString());
              double longitude = double.parse(value['longitude'].toString());

              // Calculate the distance between the user and the car mechanic
              double distance = Geolocator.distanceBetween(
                position.latitude,
                position.longitude,
                latitude,
                longitude,
              );

              // Filter the car mechanics within a certain radius (e.g., 10 kilometers)
              if (distance <= 10000) {
                CarMechanic mechanic = CarMechanic(
                  name: value['name'],
                  latitude: latitude,
                  longitude: longitude,
                );
                nearbyMechanics.add(mechanic);
              }
            });

            setState(() {
              carMechanics = nearbyMechanics;
            });
          }
        } as FutureOr Function(DatabaseEvent value));
  }

  Future<Position> getCurrentUserLocation() async {
    // Use geolocator to get the current user's location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return position;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nearby Car Mechanics'),
        ),
        body: ListView.builder(
          itemCount: carMechanics.length,
          itemBuilder: (context, index) {
            CarMechanic carMechanic = carMechanics[index];
            return ListTile(
              title: Text(carMechanic.name),
              subtitle: Text(
                'Location: (${carMechanic.latitude}, ${carMechanic.longitude})',
              ),
            );
          },
        ),
      ),
    );
  }
}
