// ignore_for_file: unnecessary_brace_in_string_interps, avoid_print

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:car_mechanics/global/global.dart';
import 'package:car_mechanics/model/user_rideservice_request_info.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'notification_dialog_box.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging(BuildContext context) async {
    // 1. Teminated
    // When the app is closed and opened directly from the push notification

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        readUserRideMechanicsRequestInformation(
            remoteMessage.data["MechanicsRequestId"], context);
      }
    });

    // 2. Foreground
    // When app is open and receives a push notification

    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      readUserRideMechanicsRequestInformation(
          remoteMessage.data["MechanicsRequestId"], context);
    });

    // 3. Background
    // When the app is in the backgound and opened directly from the push notification

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      readUserRideMechanicsRequestInformation(
          remoteMessage.data["MechanicsRequestId"], context);
    });
  }

  readUserRideMechanicsRequestInformation(
      String userRideMechanicsRequestId, BuildContext context) {
    FirebaseDatabase.instance
        .ref()
        .child("All Mechanics Requests")
        .child(userRideMechanicsRequestId)
        .child("mechanicsId")
        .onValue
        .listen((event) {
      print('Data received: ${event.snapshot.value}');
      if (event.snapshot.value == "waiting" ||
          event.snapshot.value == firebaseAuth.currentUser!.uid) {
        FirebaseDatabase.instance
            .ref()
            .child("All Mechanics Requests")
            .child(userRideMechanicsRequestId)
            .once()
            .then((snapData) {
          if (snapData.snapshot.value != null) {
            audioPlayer.open(Audio(""));
            audioPlayer.play();

            double originLat = double.parse(
                (snapData.snapshot.value! as Map)["origin"]["latutide"]);
            double originLng = double.parse(
                (snapData.snapshot.value! as Map)["origin"]["longutide"]);

            String originAddress =
                (snapData.snapshot.value as Map)["originAddress"];

            double destinationLat = double.parse(
                (snapData.snapshot.value! as Map)["destination"]["latutide"]);
            double destinationLng = double.parse(
                (snapData.snapshot.value! as Map)["destination"]["longutide"]);

            String destinationAddress =
                (snapData.snapshot.value as Map)["destinationAddress"];

            String userName = (snapData.snapshot.value! as Map)["userName"];
            String userPhone = (snapData.snapshot.value! as Map)["userPhone"];

            String? rideMechanicsRequestId = snapData.snapshot.key;

            UserRideServiceRequestInformation userRideServiceRequestDetails =
                UserRideServiceRequestInformation();
            userRideServiceRequestDetails.originLatLng =
                LatLng(originLat, originLng);
            userRideServiceRequestDetails.originAddress = originAddress;
            userRideServiceRequestDetails.destinationLatLng =
                LatLng(destinationLat, destinationLng);
            userRideServiceRequestDetails.destinationAddress =
                destinationAddress;

            userRideServiceRequestDetails.userName = userName;
            userRideServiceRequestDetails.userPhone = userPhone;

            userRideServiceRequestDetails.rideMechanicsRequestId =
                rideMechanicsRequestId;

            showDialog(
                context: context,
                builder: (BuildContext context) => NotificationDialogBox(
                      userRideServiceRequesDetails:
                          userRideServiceRequestDetails,
                    ));
          } else {
            Fluttertoast.showToast(
                msg: "This Mechanics Request Id do not exist.");
          }
        });
      } else {
        Fluttertoast.showToast(
            msg: "This Mechanics Request has been cancelled.");
        Navigator.pop(context);
      }
    });
  }

  Future generateAndGetToken() async {
    String? registrationToken = await messaging.getToken();
    print("FCM Registration Token: ${registrationToken}");

    FirebaseDatabase.instance
        .ref()
        .child("acim_mechanics")
        .child(firebaseAuth.currentUser!.uid)
        .child("token")
        .set(registrationToken);

    messaging.subscribeToTopic("allMechanics");
    messaging.subscribeToTopic("allUsers");
  }
}
