// ignore_for_file: must_be_immutable, unused_field, prefer_collection_literals, use_build_context_synchronously, unused_local_variable, unrelated_type_equality_checks, prefer_typing_uninitialized_variables, unnecessary_null_comparison

import 'dart:async';

import 'package:car_mechanics/global/progress_dialog.dart';
import 'package:car_mechanics/model/user_rideservice_request_info.dart';
import 'package:car_mechanics/requestMethod/request_method.dart';
import 'package:car_mechanics/splashScreen/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';

import '../global/global.dart';

class NewMechanicsTripe extends StatefulWidget {
  NewMechanicsTripe({super.key, this.userRideServiceRequestDetails});

  UserRideServiceRequestInformation? userRideServiceRequestDetails;

  @override
  State<NewMechanicsTripe> createState() => _NewMechanicsTripeState();
}

class _NewMechanicsTripeState extends State<NewMechanicsTripe> {
  GoogleMapController? newTripMechanicsGoogleMapController;

  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  String? buttonTitle = "Arrived";
  Color? buttonColor = Colors.green;

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircles = Set<Circle>();
  Set<Polyline> setOfPolylines = Set<Polyline>();
  List<LatLng> polylinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  BitmapDescriptor? iconAnimatedMarker;
  var geoLocator = Geolocator();
  Position? onlineDriveMechanicsCurrentPostion;

  String rideMechanicsStatus = "accepted";

  String durationFromOriginToDestination = "";

  bool isRequestDiractionDetails = false;

  // step 1: when Mechanics/Driver accepts the user services request
  // OriginLatLng = driverMechanicsCurrent Location
  // destinationLatLng = userPickUpLocation

  // step 2: When mechanics picks/services up the user in his car
  // originLatLtng = userCurrentLocation which will be also the currentLocation of the mechanics at that time
  // destinationLatLng = User's drop-Off Location

  Future<void> drawPolyLineFormOrignToDestination(
      LatLng originLatLng, LatLng destinationLatLng) async {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          const ProgressDialog(message: "Please wait..."),
    );

    var directionDetailsInfo =
        await RequestMethod.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);

    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo.ePoints!);

    polylinePositionCoordinates.clear();

    if (decodedPolylinePointsResultList.isNotEmpty) {
      for (var pointLatLng in decodedPolylinePointsResultList) {
        polylinePositionCoordinates.add(
          LatLng(pointLatLng.latitude, pointLatLng.longitude),
        );
      }
    }

    setOfPolylines.clear();

    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId("PolylineID"),
        color: Colors.blue,
        jointType: JointType.round,
        points: polylinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );

      setOfPolylines.add(polyline);
    });

    LatLngBounds boundsLatLng;

    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(
          destinationLatLng.latitude,
          originLatLng.longitude,
        ),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(
          originLatLng.latitude,
          destinationLatLng.longitude,
        ),
      );
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newTripMechanicsGoogleMapController!.animateCamera(
      CameraUpdate.newLatLngBounds(boundsLatLng, 65),
    );

    Marker originMarker = Marker(
      markerId: const MarkerId("originMarker"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationMarker"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originCircle"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationCircle"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      setOfCircles.add(originCircle);
      setOfCircles.add(destinationCircle);
    });
  }

  @override
  void initState() {
    super.initState();

    saveAssignedDriverMechanicsDetailsToUserRequest();
  }

  getDrivesMechanicsLocationUpdatesAtRealTime() {
    LatLng oldLatlng = const LatLng(0, 0);

    streamSubscriptionMechanicsLivePosition =
        Geolocator.getPositionStream().listen((Position position) {
      dirvermechanicsCurrentPosition = position;
      onlineDriveMechanicsCurrentPostion = position;

      LatLng latlngLiveDriverMechanicsPosition = LatLng(
          onlineDriveMechanicsCurrentPostion!.latitude,
          onlineDriveMechanicsCurrentPostion!.longitude);

      Marker animatingMarker = Marker(
        markerId: const MarkerId("AniminatingMarker"),
        position: latlngLiveDriverMechanicsPosition,
        icon: iconAnimatedMarker!,
        infoWindow: const InfoWindow(title: "This is your position"),
      );

      setState(() {
        CameraPosition cameraPosition =
            CameraPosition(target: latlngLiveDriverMechanicsPosition, zoom: 18);
        newTripMechanicsGoogleMapController!
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        setOfMarkers.removeWhere(
            (element) => element.markerId.value == "AnimatedMarker");

        setOfMarkers.add(animatingMarker);
      });
      oldLatlng = latlngLiveDriverMechanicsPosition;
      updateDurationTimeAtRealTime();

      // Updating driver location at real Time in database

      Map driverMechanicsLatlngDataMap = {
        "latitude": onlineDriveMechanicsCurrentPostion!.latitude.toString(),
        "longitude": onlineDriveMechanicsCurrentPostion!.longitude.toString(),
      };

      FirebaseDatabase.instance
          .ref()
          .child("All Mechanics Request")
          .child(widget.userRideServiceRequestDetails!.rideMechanicsRequestId!)
          .child("mechanicsLocation")
          .set(driverMechanicsLatlngDataMap);
    });
  }

  updateDurationTimeAtRealTime() async {
    if (isRequestDiractionDetails == false) {
      isRequestDiractionDetails = true;

      if (onlineDriveMechanicsCurrentPostion == null) {
        return;
      }

      var originlatlng = LatLng(onlineDriveMechanicsCurrentPostion!.latitude,
          onlineDriveMechanicsCurrentPostion!.longitude);

      var destinationLatlng;

      if (rideMechanicsStatus == "accepted") {
        destinationLatlng = widget
            .userRideServiceRequestDetails!.originLatLng; //user PickUp Location
      } else {
        destinationLatlng =
            widget.userRideServiceRequestDetails!.destinationLatLng;
      }

      var directionInformation =
          await RequestMethod.obtainOriginToDestinationDirectionDetails(
              originlatlng, destinationLatlng);

      if (directionInformation != null) {
        setState(() {
          durationFromOriginToDestination = directionInformation.durationText!;
        });
      }
      isRequestDiractionDetails = false;
    }
  }

  createDriveMechanicsIconMarker() {
    if (iconAnimatedMarker == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(
        context,
        size: const Size(2, 2),
      );
      BitmapDescriptor.fromAssetImage(imageConfiguration, "assets/image/2.jpg")
          .then((value) {
        iconAnimatedMarker = value;
      });
    }
  }

  saveAssignedDriverMechanicsDetailsToUserRequest() {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child("All Mechanics Request")
        .child(widget.userRideServiceRequestDetails!.rideMechanicsRequestId!);

    Map driverMechanicsLocationDataMap = {
      "latitude": dirvermechanicsCurrentPosition!.latitude.toString(),
      "longutide": dirvermechanicsCurrentPosition!.longitude.toString(),
    };

    if (databaseReference.child("mechanicsId") != "waiting") {
      databaseReference
          .child("mechanicsDriverLocation")
          .set(driverMechanicsLocationDataMap);

      databaseReference.child("status").set("accepted");
      databaseReference.child("mechanicsId").set(onlineMechanicsData.id);
      databaseReference.child("mechanicsName").set(onlineMechanicsData.name);
      databaseReference.child("mechanicsPhone").set(onlineMechanicsData.phone);
      databaseReference.child("ratings").set(onlineMechanicsData.ratings);
      databaseReference.child("car_details").set(onlineMechanicsData.carModel);
      databaseReference.child("car_details").set(
          "${onlineMechanicsData.carModel} ${onlineMechanicsData.carNumber} (${onlineMechanicsData.carColor} )");

      saveRideMechanicsIdToMechanicsHistory();
    } else {
      Fluttertoast.showToast(
          msg:
              "This Service is already accepted by another car Mechanics. \n Reload App");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        ),
      );
    }
  }

  saveRideMechanicsIdToMechanicsHistory() {
    DatabaseReference tripMechanicsServicesHistoryRef = FirebaseDatabase
        .instance
        .ref()
        .child("acim_mechanics")
        .child(firebaseAuth.currentUser!.uid)
        .child("tripServiceHistory");

    tripMechanicsServicesHistoryRef
        .child(widget.userRideServiceRequestDetails!.rideMechanicsRequestId!)
        .set(true);
  }

  endTripServiceNow() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ProgressDialog(message: "Please wait..."),
    );

    // get the tripDirectionDetails = distance services/Travelled

    var currentDriverMechanicsLatlng = LatLng(
        onlineDriveMechanicsCurrentPostion!.latitude,
        onlineDriveMechanicsCurrentPostion!.longitude);

    var tripDirectionDetails =
        await RequestMethod.obtainOriginToDestinationDirectionDetails(
            currentDriverMechanicsLatlng,
            widget.userRideServiceRequestDetails!.originLatLng!);
    // fare Amount

    double totalFareAmount =
        RequestMethod.calculateFareAmountFromOriginToDestion(
            tripDirectionDetails);

    FirebaseDatabase.instance
        .ref()
        .child("All Mechanics Request")
        .child(widget.userRideServiceRequestDetails!.rideMechanicsRequestId!)
        .child("fareAmount")
        .set(totalFareAmount.toString());

    FirebaseDatabase.instance
        .ref()
        .child("All Mechanics Request")
        .child(widget.userRideServiceRequestDetails!.rideMechanicsRequestId!)
        .child("status")
        .set("ended");

    Navigator.pop(context);

    // display fare amount  in dialog box

    // showDialog(context: context, builder: builder)

    // save fare amount to driver total earnings
    // savefareAmount
  }

  @override
  Widget build(BuildContext context) {
    // createDriveMechanicsIconMarker();
    return Scaffold(
      body: Stack(
        children: [
          // Google Map

          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            markers: setOfMarkers,
            circles: setOfCircles,
            polylines: setOfPolylines,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);

              newTripMechanicsGoogleMapController = controller;

              setState(() {
                mapPadding = 350;
              });

              var driverMechanicsCurrentLatLng = LatLng(
                  dirvermechanicsCurrentPosition!.latitude,
                  dirvermechanicsCurrentPosition!.longitude);

              var userPickLatLng =
                  widget.userRideServiceRequestDetails!.originLatLng;

              drawPolyLineFormOrignToDestination(
                  driverMechanicsCurrentLatLng, userPickLatLng!);

              getDrivesMechanicsLocationUpdatesAtRealTime();
            },
          ),
          // A Button for createDriveMechanicsIconMarker();
          // Positioned(
          //   left: 0,
          //   right: 0,
          //   top: 30,
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: Colors.black,
          //       borderRadius: BorderRadius.circular(20),
          //     ),
          //     child: ElevatedButton.icon(
          //       onPressed: () {
          //         createDriveMechanicsIconMarker();
          //       },
          //       icon: const Icon(Icons.push_pin),
          //       label: const Text("createDriveMechanicsIconMarker"),
          //     ),
          //   ),
          // ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 18,
                      spreadRadius: 0.5,
                      offset: Offset(0.6, 0.6),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        durationFromOriginToDestination,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(
                        thickness: 1,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.userRideServiceRequestDetails!.userName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.phone,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
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
                                  widget.userRideServiceRequestDetails!
                                      .originAddress!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
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
                                  widget.userRideServiceRequestDetails!
                                      .destinationAddress!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(
                            thickness: 1,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                              onPressed: () async {
                                // [Mechanics has arrived at user PickUpLocation] - Arrived Button

                                if (rideMechanicsStatus == "accepted") {
                                  rideMechanicsStatus = "arrived";

                                  FirebaseDatabase.instance
                                      .ref()
                                      .child("All Mechanics Request")
                                      .child(widget
                                          .userRideServiceRequestDetails!
                                          .rideMechanicsRequestId!)
                                      .child("status")
                                      .set(rideMechanicsStatus);

                                  setState(() {
                                    buttonTitle = "Let's Go";
                                    buttonColor = Colors.lightGreen;
                                  });

                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => const ProgressDialog(
                                        message: "Loading..."),
                                  );

                                  await drawPolyLineFormOrignToDestination(
                                      widget.userRideServiceRequestDetails!
                                          .originLatLng!,
                                      widget.userRideServiceRequestDetails!
                                          .destinationLatLng!);

                                  Navigator.pop(context);
                                }

                                // [user has been picked from the user's current location] - Let's Go

                                else if (rideMechanicsStatus == "arrived") {
                                  rideMechanicsStatus = "onTripServices";

                                  FirebaseDatabase.instance
                                      .ref()
                                      .child("All Mechanics Request")
                                      .child(widget
                                          .userRideServiceRequestDetails!
                                          .rideMechanicsRequestId!)
                                      .child("status")
                                      .set(rideMechanicsStatus);

                                  setState(() {
                                    buttonTitle = "Successfully rich the end";
                                    buttonColor = Colors.red;
                                  });
                                }
                                // [user/mechanics has reached the drop Off Location] - End Trip Button

                                else if (rideMechanicsStatus ==
                                    "Successfully rich the end") {
                                  endTripServiceNow();
                                }
                              },
                              icon: const Icon(
                                Icons.directions,
                                color: Colors.black,
                                size: 25,
                              ),
                              label: Text(
                                buttonTitle!,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
