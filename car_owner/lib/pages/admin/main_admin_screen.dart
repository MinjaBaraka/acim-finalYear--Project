// ignore_for_file: use_build_context_synchronously, prefer_interpolation_to_compose_strings, avoid_print, unused_field, prefer_final_fields, prefer_collection_literals, await_only_futures, unnecessary_null_comparison, unused_local_variable, prefer_is_empty

import 'dart:async';

import 'package:car_onwer/model/active_nearby_available_mechanics.dart';
import 'package:car_onwer/pages/admin/searchcar_mechanics.dart';
import 'package:car_onwer/requestMethod/geofire_assistant.dart';
import 'package:car_onwer/splashScreen/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_geofire/flutter_geofire.dart';

import '../../global/global.dart';
import '../../global/progress_dialog.dart';
import '../../infoHandler/app_info.dart';
import '../../infoHandler/car_mechanics_details.dart';
import '../../requestMethod/request_method.dart';
import '../../widget/pay_fare_amount_dialog.dart';
import 'drawer_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({
    super.key,
  });

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();

  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  double searchLocationContainerHeight = 220;
  double waitingResponseFromMechanicsContainerHeight = 0;
  double assignedMechanicsInfoContainerHeight = 0;
  double suggestedRidesContainerHeight = 0;
  double searchingForDriverMechanicsContainer = 0;

  LatLng? pickUpLocation;
  loc.Location location = loc.Location();
  String? _address;

  Position? userCurrentPosition;
  var geoLocation = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCordinatesList = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

  String userName = "";
  String userEmail = "";

  // bool openNavigationDrawer = true;
  bool openNavigationDrawer = false;
  bool activeNearbyMechanicsKeysLoaded = false;
  bool showSuggestedRidesContainerHeight = false;

  BitmapDescriptor? activeNearbyIcon;

  String selectedMechanicsVehicleType = "";

  String mechanicsServiceStatus = "Mechanics is coming..";
  StreamSubscription<DatabaseEvent>?
      tripRideMechanicsRequestInfoStreamSubscription;

  List<ActiveNearByAvailableMechanics> onLineNearByAvailableMechanicsList = [];

  DatabaseReference? referenceMechanicsRequest;

  String userRideCarOwnerRequestStatus = "";

  String? driverMechanicsStatus;

  bool requestPositionInfo = true;

  locationUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    userCurrentPosition = cPosition;

    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 15);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await RequestMethod.searchAddressForGeographicCoordinates(
            userCurrentPosition!, context);

    print("This is our address::  " + humanReadableAddress);

    userName = userModalCurrentInfo!.name!;
    userEmail = userModalCurrentInfo!.email!;

    initialzeGeofireListener();
    //  {
    // RequestMethod.readTripsKeysForOnlineUser(context);
    // }
  }

  initialzeGeofireListener() {
    Geofire.initialize("activeMechanics");

    Geofire.queryAtLocation(
            userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
        .listen((map) {
      print(map);

      if (map != null) {
        var callBack = map["callBack"];

        switch (callBack) {
          // whenever any mechanics become active/online

          case Geofire.onKeyEntered:
            ActiveNearByAvailableMechanics activeNearByAvailableMechanics =
                ActiveNearByAvailableMechanics();
            activeNearByAvailableMechanics.locationLatitude = map["latitude"];
            activeNearByAvailableMechanics.locationLongitude = map["lonitude"];
            activeNearByAvailableMechanics.mechanicsId = map["key"];

            GeofireAssistant.activeNearByAvailableMechanicslist
                .add(activeNearByAvailableMechanics);

            if (activeNearbyMechanicsKeysLoaded == true) {
              displayActiveMechanicsOnUsersMap();
            }

            break;

          // Whenever any mechanics become non-active/online

          case Geofire.onKeyExited:
            GeofireAssistant.deleteOfflineMechanicsFromList(map["key"]);
            displayActiveMechanicsOnUsersMap();
            break;

          // whenever mechanics moves - update mechanics location

          case Geofire.onKeyMoved:
            ActiveNearByAvailableMechanics activeNearByAvailableMechanics =
                ActiveNearByAvailableMechanics();

            activeNearByAvailableMechanics.locationLatitude = map["latitude"];
            activeNearByAvailableMechanics.locationLongitude = map["lonitude"];
            activeNearByAvailableMechanics.mechanicsId = map["key"];

            GeofireAssistant.updateActiveNearByAvailableMechanicsLocation(
                activeNearByAvailableMechanics);
            displayActiveMechanicsOnUsersMap();
            break;

          // Display those online active mechanics on User's map

          case Geofire.onGeoQueryReady:
            activeNearbyMechanicsKeysLoaded = true;
            displayActiveMechanicsOnUsersMap();
            break;
        }
      }

      setState(() {});
    });
  }

  displayActiveMechanicsOnUsersMap() {
    setState(() {
      markerSet.clear();
      circleSet.clear();

      Set<Marker> mechanicsMarkerSet = Set<Marker>();

      for (ActiveNearByAvailableMechanics eachMechanics
          in GeofireAssistant.activeNearByAvailableMechanicslist) {
        LatLng eachMechanicsActivePosition = LatLng(
            eachMechanics.locationLatitude!, eachMechanics.locationLongitude!);

        Marker marker = Marker(
          markerId: MarkerId(eachMechanics.mechanicsId!),
          position: eachMechanicsActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
        );

        mechanicsMarkerSet.add(marker);
      }

      setState(() {
        markerSet = mechanicsMarkerSet;
      });
    });
  }

  createActiveNearByMechanicsIconMarker() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));

      BitmapDescriptor.fromAssetImage(imageConfiguration, "assets/image/1.jpg")
          .then((value) {
        activeNearbyIcon = value;
      });
    }
  }

  Future<void> drawPolylineFromOriginToDestination() async {
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(
        originPosition!.locationLatitude!, originPosition.locationLongtitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!,
        destinationPosition.locationLongtitude!);

    showDialog(
      context: context,
      builder: (context) => const ProgressDialog(
        message: "Please wait....",
      ),
    );

    var directionDetailsInfo =
        await RequestMethod.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);
    // print(directionDetailsInfo);

    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });

    Navigator.pop(context);

    // Create an instance of PolylinePoints

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolylinePointsResultList =
        polylinePoints.decodePolyline(directionDetailsInfo.ePoints!);

    pLineCordinatesList.clear();

    if (decodePolylinePointsResultList.isNotEmpty) {
      for (var pointLatLng in decodePolylinePointsResultList) {
        pLineCordinatesList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }

    print(decodePolylinePointsResultList
        .map((point) => point.toString())
        .toList());

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.blue,
        polylineId: const PolylineId('polylineID'),
        jointType: JointType.round,
        points: pLineCordinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );
      polylineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newGoogleMapController!.animateCamera(
      CameraUpdate.newLatLngBounds(boundsLatLng, 65),
    );

    Marker originMarker = Marker(
      markerId: const MarkerId("OrginMarkerId"),
      infoWindow:
          InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    Marker destinationaMarker = Marker(
      markerId: const MarkerId("DestinationMarkerId"),
      infoWindow: InfoWindow(
          title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      markerSet.add(originMarker);
      markerSet.add(destinationaMarker);
    });

    Circle orginCircle = Circle(
      circleId: const CircleId("CircleOrginId"),
      center: originLatLng,
      radius: 12,
      strokeColor: Colors.white,
      strokeWidth: 5,
      fillColor: Colors.green,
    );
    Circle destinationCircle = Circle(
      circleId: const CircleId("DestinationCircle"),
      center: destinationLatLng,
      radius: 12,
      strokeColor: Colors.white,
      strokeWidth: 5,
      fillColor: Colors.red,
    );

    setState(() {
      circleSet.add(orginCircle);
      circleSet.add(destinationCircle);
    });
  }

  void showSearchingForDrieverMechanicsContainer() {
    setState(() {
      searchLocationContainerHeight = 200;
    });
  }

  void toggleshowSuggestedRidesContainer() {
    setState(() {
      // showSuggestedRidesContainerHeight = !showSuggestedRidesContainerHeight;
      suggestedRidesContainerHeight = 400;
      bottomPaddingOfMap = 400;
    });
  }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  saveMechanicsRequestMechanicsInformation(
      String selectedMechanicsVehicleType) {
    // 1. save the car mechanics information

    referenceMechanicsRequest =
        FirebaseDatabase.instance.ref().child("All Mechanics Request").push();

    var originLocation =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationLocation =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    Map originLocationMap = {
      // *Key: Value

      "latitude": originLocation!.locationLatitude,
      "longitude": originLocation.locationLongtitude,
    };

    Map destinationLocationMap = {
      // *Key: Value

      "latitude": destinationLocation!.locationLatitude,
      "longitude": destinationLocation.locationLongtitude,
    };

    Map userInformationMap = {
      "origin": originLocationMap,
      "destination": destinationLocationMap,
      "time": DateTime.now().toString(),
      "userName": userModalCurrentInfo!.name,
      "userPhone": userModalCurrentInfo!.phone,
      "originAddress": originLocation.locationName,
      "destinationAddress": destinationLocation.locationName,
      "mechanicsId": "waiting",
    };

    referenceMechanicsRequest!.set(userInformationMap);

    tripRideMechanicsRequestInfoStreamSubscription =
        referenceMechanicsRequest!.onValue.listen((eventSnap) async {
      if (eventSnap.snapshot.value == null) {
        return;
      }
      if ((eventSnap.snapshot.value as Map)["car_details"] != null) {
        setState(() {
          driverMechanicsDetails =
              (eventSnap.snapshot.value as Map)["car_details"].toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)["car_mechanics_phone"] != null) {
        setState(() {
          driverMechanicsDetails =
              (eventSnap.snapshot.value as Map)["car_mechanics_phone"]
                  .toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)["car_mechanics_name"] != null) {
        setState(() {
          driverMechanicsDetails =
              (eventSnap.snapshot.value as Map)["car_mechanics_name"]
                  .toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)["status"] != null) {
        setState(() {
          userRideCarOwnerRequestStatus =
              (eventSnap.snapshot.value as Map)["status"].toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)["mechanicsLocation"] != null) {
        double driverMechanicsCurrentPositionLat = double.parse(
            (eventSnap.snapshot.value as Map)["driverMechanicsLocation"]
                    ["latitude"]
                .toString());
        double driverMechanicsCurrentPositionLng = double.parse(
            (eventSnap.snapshot.value as Map)["driverMechanicsLocation"]
                    ["longitude"]
                .toString());
        LatLng driverMechanicsCurrentPositionLatLng = LatLng(
            driverMechanicsCurrentPositionLat,
            driverMechanicsCurrentPositionLng);

        // Status = accepted

        if (userRideCarOwnerRequestStatus == "accepted") {
          updateArriveTimeToUserPickUpLocation(
              driverMechanicsCurrentPositionLatLng);
        }
        // status = arrived
        if (userRideCarOwnerRequestStatus == "arrived") {
          setState(() {
            driverMechanicsStatus = "Driver Car Mechanics has Arrived";
          });
        }

        // Satus = onTrip/Services

        if (userRideCarOwnerRequestStatus == "onTrip/Services") {
          updateReachingTimeToUserDropOffLocation(
              driverMechanicsCurrentPositionLatLng);
        }

        if (userRideCarOwnerRequestStatus == "Ended") {
          if ((eventSnap.snapshot.value as Map)["fareAmount"] != null) {
            double fareAmount = double.parse(
                (eventSnap.snapshot.value as Map)["farAmount"].toString());

            var respone = await showDialog(
              context: context,
              builder: (context) => PayFareAmountDialog(fareAmount: fareAmount),
            );

            // User car Owner can rating driver car Mechanics now

            if (respone == "cash Paid") {
              if ((eventSnap.snapshot.value as Map)["mehanicsId"] != null) {
                String assignedMechanicsId =
                    (eventSnap.snapshot.value as Map)["mechanicsId"].toString();
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const RateMechanicsScreen(),
                //   ),
                // );

                referenceMechanicsRequest!.onDisconnect();
                tripRideMechanicsRequestInfoStreamSubscription!.cancel();
              }
            }
          }
        }
      }
    });

    onLineNearByAvailableMechanicsList =
        GeofireAssistant.activeNearByAvailableMechanicslist;

    searchNearestOnlineMechanics(selectedMechanicsVehicleType);
  }

  searchNearestOnlineMechanics(String selectedMechanicsVehicleType) async {
    if (onLineNearByAvailableMechanicsList.length == 0) {
      // cancel/Delete the ride/Mechanics service request Information

      referenceMechanicsRequest!.remove();

      setState(() {
        polylineSet.clear();
        markerSet.clear();
        circleSet.clear();
        pLineCordinatesList.clear();
      });

      Fluttertoast.showToast(msg: "No online nearest Car Mechanics Available");
      Fluttertoast.showToast(msg: "Search Again. \n Restart App");

      Future.delayed(const Duration(milliseconds: 4000), () {
        referenceMechanicsRequest!.remove();
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SplashScreen(),
            ));
      });
      return;
    }

    await retrieveOnlineMechanicsInformation(
        onLineNearByAvailableMechanicsList);

    print("Mechanics List: " + driverMechanicsList.toString());

    for (int i = 0; i < driverMechanicsList.length; i++) {
      if (driverMechanicsList[i]["car_mechanics_details"]["type"] ==
          selectedMechanicsVehicleType) {
        RequestMethod.sendNitificationToMechanicsNow(
            driverMechanicsList[i]["token"],
            referenceMechanicsRequest!.key!,
            context);
      }
    }
    Fluttertoast.showToast(msg: "Notitfication sent Successfully");

    showSearchingForDrieverMechanicsContainer();

    await FirebaseDatabase.instance
        .ref()
        .child("All Mechanics Request")
        .child(referenceMechanicsRequest!.key!)
        .child("acim_mechanics")
        .onValue
        .listen((eventRideMechanicsRequestSpanShot) {
      print(
          "EventSnapShot: ${eventRideMechanicsRequestSpanShot.snapshot.value}");

      if (eventRideMechanicsRequestSpanShot.snapshot.value != null) {
        if (eventRideMechanicsRequestSpanShot.snapshot.value != "waiting") {
          showUIForAssignedDriverMechanicsInfo();
        }
      }
    });
  }

  updateArriveTimeToUserPickUpLocation(
      driverMechanicsCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      LatLng userPickUpPosition =
          LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

      var directionDetailsInfo =
          await RequestMethod.obtainOriginToDestinationDirectionDetails(
              driverMechanicsCurrentPositionLatLng, userPickUpPosition);

      if (directionDetailsInfo == null) {
        return;
      }

      setState(() {
        driverMechanicsStatus = "Mechanics is coming.." +
            directionDetailsInfo.durationText.toString();
      });

      requestPositionInfo = true;
    }
  }

  updateReachingTimeToUserDropOffLocation(
      driverMechanicsCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      var dropOffLocation =
          Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

      LatLng userDestinationPosition = LatLng(
          dropOffLocation!.locationLatitude!,
          dropOffLocation.locationLongtitude!);

      var directionDetailsInfo =
          await RequestMethod.obtainOriginToDestinationDirectionDetails(
              driverMechanicsCurrentPositionLatLng, userDestinationPosition);

      if (directionDetailsInfo == null) {
        return;
      }

      setState(() {
        driverMechanicsStatus = "Going Towards Destination.." +
            directionDetailsInfo.durationText.toString();
      });

      requestPositionInfo = true;
    }
  }

  showUIForAssignedDriverMechanicsInfo() {
    setState(() {
      waitingResponseFromMechanicsContainerHeight = 0;
      searchLocationContainerHeight = 0;
      assignedMechanicsInfoContainerHeight = 200;
      suggestedRidesContainerHeight = 0;
      bottomPaddingOfMap = 200;
    });
  }

  retrieveOnlineMechanicsInformation(List onLineNearestMechanicsList) async {
    driverMechanicsList.clear();
    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child("acim_mechanics");

    for (int i = 0; i < onLineNearestMechanicsList.length; i++) {
      await ref
          .child(onLineNearestMechanicsList[i].mechanicsId.toString())
          .once()
          .then((dataSnapshot) {
        var driverMechanicsKeyInfo = dataSnapshot.snapshot.value;

        driverMechanicsList.add(driverMechanicsKeyInfo);

        print("Driver/Mechanics Key Information = " +
            driverMechanicsList.toString());
      });
    }
  }

  @override
  void initState() {
    super.initState();

    checkIfLocationPermissionAllowed();
  }

  @override
  Widget build(BuildContext context) {
    // createActiveNearByMechanicsIconMarker();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldState,
          drawer: const DrawerScreen(),
          body: Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                myLocationEnabled: true,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: true,
                polylines: polylineSet,
                markers: markerSet,
                circles: circleSet,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  _controllerGoogleMap.complete(controller);

                  newGoogleMapController = controller;

                  setState(() {
                    bottomPaddingOfMap = 20;
                  });

                  locationUserPosition();
                },
              ),
              Positioned(
                top: 20,
                left: 20,
                child: GestureDetector(
                  onTap: () {
                    _scaffoldState.currentState!.openDrawer();
                  },
                  child: const CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Icon(
                      Icons.menu,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Container for createActiveNearByMechanicsIconMarker()
              Positioned(
                  top: 65,
                  left: 60,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        createActiveNearByMechanicsIconMarker();
                      },
                      icon: const Icon(Icons.add),
                      label:
                          const Text("createActiveNearByMechanicsIconMarker"),
                    ),
                  )),
              Positioned(
                bottom: 80,
                right: 0,
                left: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25, 55, 25, 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          color: Colors.amber.shade400,
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Your Current Location",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              Provider.of<AppInfo>(context)
                                                          .userPickUpLocation !=
                                                      null
                                                  ? (Provider.of<AppInfo>(
                                                                  context)
                                                              .userPickUpLocation!
                                                              .locationName!)
                                                          .substring(0, 24) +
                                                      "...."
                                                  : "Not Getting Address",
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Divider(
                                    height: 1,
                                    thickness: 2,
                                    color: Colors.amber.shade400,
                                  ),
                                  const SizedBox(height: 5),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: GestureDetector(
                                      onTap: () async {
                                        var responseFromSearchScreen =
                                            await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const CarMechanicListScreen(),
                                          ),
                                        );

                                        if (responseFromSearchScreen ==
                                            "ObtainedDropOff") {
                                          setState(() {
                                            openNavigationDrawer = true;
                                          });
                                        }
                                        await drawPolylineFromOriginToDestination();
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            color: Colors.amber.shade400,
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Car Mechanics",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              // Text(
                                              //   Provider.of<CarMechanicsDetails>(
                                              //                   context)
                                              //               .selectCarMechanics !=
                                              //           null
                                              //  /     ? (Provider.of<CarMechanicsDetails>(
                                              //                       context)
                                              //                   .selectCarMechanics!
                                              //                   .name!)
                                              //               .substring(0, 24) +
                                              //           "...."
                                              //       : "Select the car mechaincs from the list",
                                              //   style: const TextStyle(
                                              //       color: Colors.grey,
                                              //       fontSize: 14),
                                              // ),

                                              openNavigationDrawer == false
                                                  ? const Text(
                                                      "Select the car mechaincs from the list",
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 14,
                                                      ),
                                                    )
                                                  : Text(
                                                      // Provider.of<CarMechanicsDetails>(
                                                      //         context)
                                                      //     .selectCarMechanics!
                                                      //     .name!,
                                                      Provider.of<CarMechanicsDetails>(
                                                                  context)
                                                              .selectCarMechanics
                                                              ?.name ??
                                                          "No car mechanics selected",
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // ElevatedButton(
                                //   onPressed: () {
                                //     Navigator.push(
                                //         context,
                                //         MaterialPageRoute(
                                //           builder: (context) =>
                                //               const PrecisePickUpLocation(),
                                //         ));
                                //   },
                                //   style: ElevatedButton.styleFrom(
                                //     textStyle: const TextStyle(
                                //       fontWeight: FontWeight.bold,
                                //       fontSize: 16,
                                //     ),
                                //   ),
                                //   child: const Text("change Pick Up Address"),
                                // ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    if (Provider.of<AppInfo>(context,
                                                listen: false)
                                            .userDropOffLocation!
                                            .locationName !=
                                        null) {
                                      toggleshowSuggestedRidesContainer();
                                    } else {
                                      Fluttertoast.showToast(
                                          msg:
                                              "Please choose car mechanics near you.");
                                    }
                                    // toggleshowSuggestedRidesContainer();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  child: const Text("Request car mechanics"),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // Request a RideMechanics
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: searchingForDriverMechanicsContainer,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const LinearProgressIndicator(
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 10),
                        const Center(
                          child: Text(
                            "Searching for a Mechanics...",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            referenceMechanicsRequest!.remove();
                            setState(() {
                              searchingForDriverMechanicsContainer = 0;
                              suggestedRidesContainerHeight = 0;
                            });
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              ),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 25,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        const SizedBox(
                          width: double.infinity,
                          child: Text(
                            "Cancel",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // UI for Suggested rides

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: suggestedRidesContainerHeight,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: const Icon(
                                Icons.star,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              Provider.of<AppInfo>(context)
                                          .userPickUpLocation !=
                                      null
                                  ? (Provider.of<AppInfo>(context)
                                      .userPickUpLocation!
                                      .locationName!)
                                  //     .substring(0, 24) +
                                  // "...."
                                  : "Where to..?",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: const Icon(
                                Icons.star,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              Provider.of<AppInfo>(context)
                                          .userDropOffLocation !=
                                      null
                                  ? (Provider.of<AppInfo>(context)
                                      .userDropOffLocation!
                                      .locationName!)
                                  //     .substring(0, 24) +
                                  // "...."
                                  : "Where to..?",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "SUGGESTED MECHANICS",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedMechanicsVehicleType =
                                      "Car mechanics";
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: selectedMechanicsVehicleType ==
                                          "Car Mechanics"
                                      ? Colors.grey
                                      : Colors.black,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(25),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        "assets/image/2.jpg",
                                        scale: 2,
                                        width: 50,
                                        height: 50,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Car Mechanics",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: selectedMechanicsVehicleType ==
                                                  "Car Mechanics"
                                              ? Colors.black
                                              : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        // "Fare amount",
                                        tripDirectionDetailsInfo != null
                                            ? "Tz ${((RequestMethod.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!) * 2) * 107).toStringAsFixed(1)}"
                                            : "Null",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedMechanicsVehicleType =
                                      "CNG mechanics";
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: selectedMechanicsVehicleType ==
                                          "CNG Mechanics"
                                      ? Colors.grey
                                      : Colors.black,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(25),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        "assets/image/2.jpg",
                                        scale: 2,
                                        width: 50,
                                        height: 50,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "CNG Mechanics",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: selectedMechanicsVehicleType ==
                                                  "CNG Mechanics"
                                              ? Colors.black
                                              : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        // "Fare amount",
                                        tripDirectionDetailsInfo != null
                                            ? "Tz ${((RequestMethod.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!) * 1.5) * 107).toStringAsFixed(1)}"
                                            : "Null",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (selectedMechanicsVehicleType != "") {
                                saveMechanicsRequestMechanicsInformation(
                                    selectedMechanicsVehicleType);
                              } else {
                                Fluttertoast.showToast(
                                    msg:
                                        "Please select a type of services from \n suggested car mechanics");
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(19),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  "Request Car Mechanics",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

                                                // const SearchPlacesScreen(),
                                                // builder: (context) =>
                                                // const SearchCarMechanics(),