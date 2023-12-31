// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'dart:async';

import 'package:car_mechanics/pushNotification/push_notification_system.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../global/global.dart';
import '../requestMethod/request_method.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  GoogleMapController? newGoogleMapController;

  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;

  String statusText = "Now Offline";
  Color buttonColor = Colors.grey;
  bool isMechanicsActive = false;

  locationMechanicsPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    dirvermechanicsCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(dirvermechanicsCurrentPosition!.latitude,
        dirvermechanicsCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 15);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await RequestMethod.searchAddressForGeographicCoordinates(
            dirvermechanicsCurrentPosition!, context);

    print("This is our address::  " + humanReadableAddress);
  }

  readCurrentMechanicsInformation() async {
    currentUser = firebaseAuth.currentUser;

    FirebaseDatabase.instance
        .ref()
        .child("acim_mechanics")
        .child(currentUser!.uid)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        Map snapshotData = snap.snapshot.value as Map;

        if (snapshotData.containsKey("car_details") &&
            snapshotData["car_details"] is Map) {
          Map carDetails = snapshotData["car_details"];

          onlineMechanicsData.carColor = carDetails.containsKey("car_color")
              ? carDetails["car_color"]
              : "default color";
          onlineMechanicsData.carModel = carDetails.containsKey("car_model")
              ? carDetails["car_model"]
              : "default model";
          onlineMechanicsData.carNumber = carDetails.containsKey("car_number")
              ? carDetails["car_number"]
              : "default number";
          onlineMechanicsData.carType = carDetails.containsKey("car_type")
              ? carDetails["car_type"]
              : "default type";
        } else {
          onlineMechanicsData.carColor = "default color";
          onlineMechanicsData.carModel = "default model";
          onlineMechanicsData.carNumber = "default number";
          onlineMechanicsData.carType = "default type";
        }
      } else {
        onlineMechanicsData.carColor = "default color";
        onlineMechanicsData.carModel = "default model";
        onlineMechanicsData.carNumber = "default number";
        onlineMechanicsData.carType = "default type";
      }
    });
  }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  void initializePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    dirvermechanicsCurrentPosition = position;
    updateMechanicsLocationAtRealTime();
  }

  @override
  void initState() {
    super.initState();

    initializePosition();

    checkIfLocationPermissionAllowed();

    readCurrentMechanicsInformation();

    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                padding: const EdgeInsets.only(top: 40),
                mapType: MapType.normal,
                myLocationEnabled: true,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: true,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  _controllerGoogleMap.complete(controller);

                  newGoogleMapController = controller;

                  locationMechanicsPosition();
                },
              ),

              // Ui for Online/Offline Mechanics
              statusText != "Now Online"
                  ? Container(
                      height: MediaQuery.of(context).size.height,
                      width: double.infinity,
                      color: Colors.black87,
                    )
                  : Container(),

              // Button for Online/Offline mechanics

              Positioned(
                top: statusText != "Now Online"
                    ? MediaQuery.of(context).size.height * 0.45
                    : 40,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (isMechanicsActive != true) {
                          mechanicsOnlineNow();
                          updateMechanicsLocationAtRealTime();

                          setState(() {
                            statusText = "Now Online";
                            isMechanicsActive = true;
                            buttonColor = Colors.transparent;
                          });
                        } else {
                          mechanicsOfflineNow();

                          setState(() {
                            statusText = "Now Offline";
                            isMechanicsActive = false;
                            buttonColor = Colors.grey;
                          });
                          Fluttertoast.showToast(msg: "You are Offline now");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          )),
                      child: statusText != "Now Online"
                          ? Text(
                              statusText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.phonelink_ring,
                              color: Colors.white,
                              size: 26,
                            ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  mechanicsOnlineNow() async {
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    dirvermechanicsCurrentPosition = pos;

    Geofire.initialize("activeMechanics");
    Geofire.setLocation(
        currentUser!.uid,
        dirvermechanicsCurrentPosition!.latitude,
        dirvermechanicsCurrentPosition!.longitude);

    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child("acim_mechanics")
        .child(currentUser!.uid)
        .child("newMechanicsServiceStatus");

    ref.set("Online");

    ref.onValue.listen((event) {});
  }

  // updateMechanicsLocationAtRealTime() {
  //   streamSubscriptionPosition =
  //       Geolocator.getPositionStream().listen((Position position) {
  //     if (isMechanicsActive == true) {
  //       Geofire.setLocation(
  //           currentUser!.uid,
  //           dirvermechanicsCurrentPosition!.latitude,
  //           dirvermechanicsCurrentPosition!.longitude);
  //     }

  //     LatLng latLng = LatLng(dirvermechanicsCurrentPosition!.latitude,
  //         dirvermechanicsCurrentPosition!.longitude);

  //     newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
  //   });
  // }

  updateMechanicsLocationAtRealTime() {
    streamSubscriptionPosition =
        Geolocator.getPositionStream().listen((Position position) {
      if (isMechanicsActive == true) {
        // Check if currentUser and dirvermechanicsCurrentPosition are not null
        if (currentUser != null && dirvermechanicsCurrentPosition != null) {
          Geofire.setLocation(
              currentUser!.uid,
              dirvermechanicsCurrentPosition!.latitude,
              dirvermechanicsCurrentPosition!.longitude);
        } else {
          print('currentUser or dirvermechanicsCurrentPosition is null');
        }
      }

      // Check if dirvermechanicsCurrentPosition is not null
      if (dirvermechanicsCurrentPosition != null) {
        LatLng latLng = LatLng(dirvermechanicsCurrentPosition!.latitude,
            dirvermechanicsCurrentPosition!.longitude);

        // Check if newGoogleMapController is not null
        if (newGoogleMapController != null) {
          newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
        } else {
          print('newGoogleMapController is null');
        }
      } else {
        print('dirvermechanicsCurrentPosition is null');
      }
    });
  }

  mechanicsOfflineNow() {
    Geofire.removeLocation(currentUser!.uid);

    DatabaseReference? ref = FirebaseDatabase.instance
        .ref()
        .child("acim_mechanics")
        .child(currentUser!.uid)
        .child("newMechanicsServiceStatus");

    ref.onDisconnect();
    ref.remove();
    ref = null;

    Future.delayed(const Duration(milliseconds: 2000), () {
      SystemChannels.platform.invokeMethod("SystemNavigator.pop");
    });
  }
}
