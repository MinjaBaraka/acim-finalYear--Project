// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../global/global.dart';
import '../global/mapkey.dart';
import '../infoHandler/app_info.dart';
import '../model/all_user_model.dart';
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

  static pauseLiveLocationUpdates() {
    streamSubscriptionPosition!.pause();

    Geofire.removeLocation(firebaseAuth.currentUser!.uid);
  }

  static double calculateFareAmountFromOriginToDestion(
      DirectionDetailsInfo directionDetailsInfo) {
    double timeTravelledFareAmountPerMinute =
        (directionDetailsInfo.durationValue! / 60) * 0.1;

    double distanceTravelFareAmountPerKilometer =
        (directionDetailsInfo.durationValue! / 100);

    double totalFareAmount =
        timeTravelledFareAmountPerMinute + distanceTravelFareAmountPerKilometer;

    double localCurrencyTotalFare = totalFareAmount * 107;

    if (driverMechanicsVehicleType == "Bike") {
      double resultFareAmount = (localCurrencyTotalFare.truncate()) * 0.8;
      resultFareAmount;
    } else if (driverMechanicsVehicleType == "CNG") {
      double resultFareAmount = (localCurrencyTotalFare.truncate()) * 1.5;
      resultFareAmount;
    } else if (driverMechanicsVehicleType == "Car") {
      double resultFareAmount = (localCurrencyTotalFare.truncate()) * 2;
      resultFareAmount;
    } else {
      return localCurrencyTotalFare.truncate().toDouble();
    }
    return localCurrencyTotalFare.truncate().toDouble();
  }
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
