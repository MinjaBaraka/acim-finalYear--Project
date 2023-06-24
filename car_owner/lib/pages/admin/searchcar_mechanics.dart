// ignore_for_file: avoid_print
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../infoHandler/car_mechanics_details.dart';

class CarMechanicListScreen extends StatefulWidget {
  const CarMechanicListScreen({super.key});

  @override
  State<CarMechanicListScreen> createState() => _CarMechanicListScreenState();
}

class _CarMechanicListScreenState extends State<CarMechanicListScreen> {
  // fecthCarMechanicsWhoIsOnline() {
  //   DatabaseReference mechanicsRef =
  //       FirebaseDatabase.instance.ref().child("acim_mechanics");

  //   List<CarMechanic> onlineMechanics = [];

  //   mechanicsRef
  //       .orderByChild("newMechanicsServiceStatus")
  //       .equalTo("Online")
  //       .once()
  //       .then((DatabaseEvent carMechanicsEvent) {
  //     DataSnapshot carMechanicsSnapshot = carMechanicsEvent.snapshot;
  //     if (carMechanicsSnapshot.value != null) {
  //       Map<dynamic, dynamic> carMechanicsData =
  //           carMechanicsSnapshot.value as Map<dynamic, dynamic>;

  //       carMechanicsData.forEach((key, value) {
  //         CarMechanic carMechanics = CarMechanic(
  //           key: key.toString(),
  //           name: value["name"],
  //           locationLatMechanics: double.parse(value["Latitude"].toString()),
  //           locationLngMechanics: double.parse(value["Longutide"].toString()),
  //         );
  //         onlineMechanics.add(carMechanics);
  //       });

  //       print(onlineMechanics);
  //     }
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
          body: Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(16),
            ),
            // child: ElevatedButton(
            //   onPressed: () {
            //     fecthCarMechanicsWhoIsOnline();
            //   },
            //   child: const Text("Click to Print Online"),
            // ),
            child: FirebaseAnimatedList(
              query: FirebaseDatabase.instance
                  .ref()
                  .child("acim_mechanics")
                  .orderByChild("newMechanicsServiceStatus")
                  .equalTo("Online"),
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                Map carMechanicsSnapshot = snapshot.value as Map;
                String carMechanicsName = carMechanicsSnapshot["name"];
                // print(carMechanicsSnapshot);

                return ListTile(
                  title: Text(carMechanicsName),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Provider.of<CarMechanicsDetails>(context, listen: false)
                          .selectCarMechanics;
                      // print(carMechanicsName);
                      Navigator.pop(context, "ObtainedDropOff");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    child: const Text("Pick Mechanics"),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

              // Column(
              //   children: [
              //     Expanded(
              //       child: Column(
              //         children: [
              //           FirebaseAnimatedList(
              //             query: FirebaseDatabase.instance
              //                 .ref()
              //                 .child("acim_mechanics")
              //                 .orderByChild("newMechanicsServiceStatus")
              //                 .equalTo("Online"),
              //             itemBuilder: (BuildContext context, DataSnapshot snapshot,
              //                 Animation<double> animation, int index) {
              //               Map carMechanicsSnapshot = snapshot.value as Map;
              //               // print(carMechanicsSnapshot);

              //               return ListTile(
              //                 title: Text(carMechanicsSnapshot["name"]),
              //                 subtitle: Text(
              //                   'Location: ${carMechanicsSnapshot['latitude']}, ${carMechanicsSnapshot['longitude']}',
              //                 ),
              //               );
              //             },
              //           ),
              //           ElevatedButton(
              //             onPressed: () {
              //               Navigator.pop(context);
              //             },
              //             child: const Text("Select Car Mechanic"),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),

