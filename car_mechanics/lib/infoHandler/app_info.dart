import 'package:flutter/material.dart';

import '../model/directions_model.dart';

class AppInfo extends ChangeNotifier {
  Directions? userPickUpLocation, userDropOffLocation;
  int countTotalTrips = 0;

  // List<String> historyTripsKeysList = [];
  // List<TripsHistoryModel> allTripsHistoryInfomationList = [];

  void updatePickUpLocationAddress(Directions userPickUpAddress) {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions userDropOffAddress) {
    userDropOffLocation = userDropOffAddress;
    notifyListeners();
  }
}
