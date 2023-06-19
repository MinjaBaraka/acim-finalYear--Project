import 'package:car_onwer/model/car_mechanic.dart';
import 'package:flutter/material.dart';

class CarMechanicsDetails extends ChangeNotifier {
  CarMechanic? selectCarMechanics;

  void pickCarMechanisWhoOnlineOnly(CarMechanic selectCarMechanicsAddress) {
    selectCarMechanics = selectCarMechanicsAddress;
    notifyListeners();
  }
}
