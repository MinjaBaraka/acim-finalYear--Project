// ignore_for_file: must_be_immutable

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:car_mechanics/global/global.dart';
import 'package:car_mechanics/model/user_rideservice_request_info.dart';
import 'package:car_mechanics/requestMethod/request_method.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../screen/new_mechanics_tripe.dart';

class NotificationDialogBox extends StatefulWidget {
  UserRideServiceRequestInformation? userRideServiceRequesDetails;
  NotificationDialogBox({super.key, this.userRideServiceRequesDetails});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              onlineMechanicsData.carType == "Car Mechanics"
                  ? "assets/image/2.jpg"
                  : onlineMechanicsData.carType == "CNG Mechanics"
                      ? "assets/image/2.jpg"
                      : "assets/image/2.jpg",
            ),
            const SizedBox(height: 10),
            // Title
            const Text(
              "New Mechanics Request",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 15),

            const Divider(
              height: 2,
              thickness: 2,
              color: Colors.blue,
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/image/2.jpg",
                      width: 30,
                      height: 30,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.userRideServiceRequesDetails!.originAddress!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Image.asset(
                      "assets/image/1.jpg",
                      width: 30,
                      height: 30,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(
                      widget.userRideServiceRequesDetails!.destinationAddress!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    )),
                  ],
                ),
              ]),
            ),
            const Divider(
              height: 2,
              thickness: 2,
              color: Colors.blue,
            ),

            // Button for Cancelling and accepting the mechanics request

            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      audioPlayer.pause();
                      audioPlayer.stop();

                      audioPlayer = AssetsAudioPlayer();

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      "Cancel".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      audioPlayer.pause();
                      audioPlayer.stop();

                      audioPlayer = AssetsAudioPlayer();

                      acceptRideMechanicsRequest(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text(
                      "Accept".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  acceptRideMechanicsRequest(BuildContext context) {
    FirebaseDatabase.instance
        .ref()
        .child("acim_mechanics")
        .child(firebaseAuth.currentUser!.uid)
        .child("newRideMechanicsStatus")
        .once()
        .then((snap) {
      if (snap.snapshot.value == "idle") {
        FirebaseDatabase.instance
            .ref()
            .child("acim_mechanics")
            .child(firebaseAuth.currentUser!.uid)
            .child("newRideMechanicsStatus")
            .set("accepted");

        RequestMethod.pauseLiveLocationUpdates();

        // Trip Started Now - Send Mechanics to New NewMechanicsTripe

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewMechanicsTripe(
                userRideServiceRequestDetails:
                    widget.userRideServiceRequesDetails,
              ),
            ));
      } else {
        Fluttertoast.showToast(msg: "This Mechanics Request do not exists");
      }
    });
  }
}
