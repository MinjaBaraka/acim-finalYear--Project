// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, unused_local_variable

import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../global/global.dart';
import '../global/mapkey.dart';
import '../infoHandler/app_info.dart';
import '../model/all_user_model.dart';
// import '../model/carmechanics_nearby.dart';
import '../model/direction_details_info.dart';
import '../model/directions_model.dart';
import 'request_assistant.dart';

// import '../pages/admin/main_admin_screen.dart';
// import '../pages/normuser/main_normuser_screen.dart';

class RequestMethod {
  static void readCurrentOnlineUserInfo(BuildContext context) async {
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("acim_user")
        .child(currentUser!.uid);

    userRef.once().then((userSnapshot) {
      if (userSnapshot.snapshot.value != null) {
        userModalCurrentInfo = UserModal.fromSnapshot(userSnapshot.snapshot);
      }
    });
  }

  static Future<String> searchAddressForGeographicCoordinates(
      Position position, context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKeys";

    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse != "Error Occured, Failed No Response...") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongtitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }

    return humanReadableAddress;
  }

  // Create a polyline for the direction with start point and end point of
  // the user_owner and car_mechanics in this project

  static Future<DirectionDetailsInfo> obtainOriginToDestinationDirectionDetails(
      LatLng originPosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.longitude},${destinationPosition.latitude}&key=$mapKeys";

    var responseDirectionApi = await RequestAssistant.receiveRequest(
        urlOriginToDestinationDirectionDetails);

    // if (responseDirectionApi == "Error Occured, Failed No Response...") {
    //   return null;
    // }

    // Check if responseDirectionApi is null or there was an error
    if (responseDirectionApi == null ||
        responseDirectionApi["status"] != "OK") {
      throw Exception("Failed to obtain direction details");
    }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.ePoints =
        responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distanceText =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distanceValue =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];
    directionDetailsInfo.durationText =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.durationValue =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

  static double calculateFareAmountFromOriginToDestination(
      DirectionDetailsInfo directionDetailsInfo) {
    double timeTraveledFareAmountPerMinute =
        (directionDetailsInfo.durationValue! / 60) * 0.1;

    double distanceTraveledFareAmountPerKilometer =
        (directionDetailsInfo.durationValue! / 1000);

    // TZ

    double totalFareAmount = timeTraveledFareAmountPerMinute +
        distanceTraveledFareAmountPerKilometer;

    return double.parse(totalFareAmount.toStringAsFixed(1));
  }

  static sendNitificationToMechanicsNow(
      String deviceRegistrationToken,
      String userRideMechanicsRequested,
      String carMechanicsName,
      context) async {
    String destinationAddress = userDropOffAddress;

    Map<String, String> headerNotification = {
      "content-Type": "application/json",
      "Authorization": 'key=$cloudMessageServerToken',
    };

    Map bodyNotification = {
      "body": "Destination Address: \n$destinationAddress",
      "title": "New Mechanics Request",
    };

    Map dataMap = {
      "click-action": "Flutter_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "mechanicsRequestId": userRideMechanicsRequested,
      "carMechanicsName": carMechanicsName,
    };

    Map officialNotificationFormat = {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": deviceRegistrationToken,
    };

    var responseNotification = await http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat),
    );

    if (responseNotification.statusCode == 200) {
      Fluttertoast.showToast(msg: "Notification sent Successfully");
    } else {
      Fluttertoast.showToast(msg: "Notification sending Failed");
    }
  }

  // static Future<List<CarMechanic>> fetchCarMechanics() async {
  //   DatabaseReference mechanicsRef =
  //       FirebaseDatabase.instance.ref().child('car_mechanics');

  //   DataSnapshot snapshot = await mechanicsRef.once() as DataSnapshot;

  //   List<CarMechanic> carMechanics = [];

  //   if (snapshot.value != null) {
  //     Map<dynamic, dynamic> dataMap = snapshot.value as Map<dynamic, dynamic>;

  //     dataMap.forEach((key, value) {
  //       CarMechanic carMechanic = CarMechanic(
  //         name: value['name'],
  //         latitude: double.parse(value['latitude'].toString()),
  //         longitude: double.parse(value['longitude'].toString()),
  //       );

  //       carMechanics.add(carMechanic);
  //     });
  //   }

  //   return carMechanics;
  // }
}

// class RequestMethod {
//   static void readCurrentOnlineUserInfo(BuildContext context) async {
//     currentUser = firebaseAuth.currentUser;
//     DatabaseReference userRef = FirebaseDatabase.instance
//         .ref()
//         .child("acim_user")
//         .child(currentUser!.uid);

//     userRef.onValue.listen((event) {
//       if (event.snapshot.value != null) {
//         DataSnapshot snapshot = event.snapshot;
//         userModalCurrentInfo = UserModal.fromSnapshot(snapshot);
//         if (userModalCurrentInfo != null) {
//           if (userModalCurrentInfo?.role == "Car_Mechanic") {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const AdminScreen(),
//               ),
//             );
//           } else if (userModalCurrentInfo?.role == "Car_Owner") {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const NormUserScreen(),
//               ),
//             );
//           }
//         }
//       }
//     });
//   }
// }

// class RequestMethod {
//   static void readCurrentOnlineUserInfo(BuildContext context) async {
//     currentUser = firebaseAuth.currentUser;
//     DatabaseReference userRef = FirebaseDatabase.instance
//         .ref()
//         .child("acim_user")
//         .child(currentUser!.uid);

//     userRef.once().then((userSnapshot) {
//       if (userSnapshot.snapshot.value != null) {
//         userModalCurrentInfo = UserModal.fromSnapshot(userSnapshot.snapshot);
//         String role = userModalCurrentInfo!.role!;
//         if (role == 'Car_Mechanic') {
//           Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const AdminScreen(),
//               ));
//         } else if (role == 'Car_Owner') {
//           Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const NormUserScreen(),
//               ));
//         }
//       }
//     });
//   }
// }
