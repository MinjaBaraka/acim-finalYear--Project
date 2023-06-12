import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserRideServiceRequestInformation {
  LatLng? originLatLng;
  LatLng? destinationLatLng;
  String? originAddress;
  String? destinationAddress;
  String? rideMechanicsRequestId;
  String? userName;
  String? userPhone;

  UserRideServiceRequestInformation({
    this.originLatLng,
    this.originAddress,
    this.destinationLatLng,
    this.destinationAddress,
    this.rideMechanicsRequestId,
    this.userName,
    this.userPhone,
  });
}
