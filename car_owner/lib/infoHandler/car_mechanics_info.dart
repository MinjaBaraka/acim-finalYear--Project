import 'package:flutter/material.dart';

import '../model/carmechanics_nearby.dart';

class CarMechanicsInfo extends ChangeNotifier {
  CarMechanic? name;

  void selectCarMechanicsFromDatabase(CarMechanic carMechanicName) {
    name = carMechanicName;
    notifyListeners();
  }
}
