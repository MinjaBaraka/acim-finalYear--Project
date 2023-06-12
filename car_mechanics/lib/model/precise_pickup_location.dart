// ignore_for_file: prefer_interpolation_to_compose_strings, use_build_context_synchronously, avoid_print, unused_field, prefer_final_fields, unused_local_variable

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';

import '../global/mapkey.dart';
import '../infoHandler/app_info.dart';
import '../requestMethod/request_method.dart';
import 'directions_model.dart';

class PrecisePickUpLocation extends StatefulWidget {
  const PrecisePickUpLocation({super.key});

  @override
  State<PrecisePickUpLocation> createState() => _PrecisePickUpLocationState();
}

class _PrecisePickUpLocationState extends State<PrecisePickUpLocation> {
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();

  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  LatLng? pickUpLocation;
  loc.Location location = loc.Location();
  String? _address;

  Position? userCurrentPosition;

  double bottomPaddingOfMap = 0;

  String userName = "";
  String userEmail = "";

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
  }

  getAddressFromListLatLng() async {
    try {
      GeoData data = await Geocoder2.getDataFromCoordinates(
        latitude: pickUpLocation!.latitude,
        longitude: pickUpLocation!.longitude,
        googleMapApiKey: mapKeys,
      );

      setState(() {
        Directions userPickUpAddress = Directions();
        userPickUpAddress.locationLatitude = pickUpLocation!.latitude;
        userPickUpAddress.locationLongtitude = pickUpLocation!.longitude;
        userPickUpAddress.locationName = data.address;

        Provider.of<AppInfo>(context, listen: false)
            .updatePickUpLocationAddress(userPickUpAddress);

        // _address = data.address;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(top: 100, bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);

              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap = 50;
              });

              locationUserPosition();
            },
            onCameraMove: (CameraPosition? postion) {
              if (pickUpLocation != postion!.target) {
                setState(() {
                  pickUpLocation = postion.target;
                });
              }
            },
            onCameraIdle: () {
              getAddressFromListLatLng();
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPaddingOfMap, top: 60),
              child: Image.asset(
                "assets/image/2.jpg",
                height: 45,
                width: 45,
              ),
            ),
          ),
          Positioned(
            top: 55,
            right: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                ),
                color: Colors.white,
              ),
              child: Text(
                Provider.of<AppInfo>(context).userPickUpLocation != null
                    ? (Provider.of<AppInfo>(context)
                                .userPickUpLocation!
                                .locationName!)
                            .substring(0, 24) +
                        "...."
                    : "Not Getting Address",
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Set Currect Location")),
            ),
          ),
        ],
      ),
    );
  }
}
