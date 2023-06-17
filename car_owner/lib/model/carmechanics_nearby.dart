import 'package:firebase_database/firebase_database.dart';

class CarMechanic {
  String? name;

  CarMechanic({
    this.name,
  });

  CarMechanic.fromSnapshot(DataSnapshot userSnapshot) {
    name = (userSnapshot.value as dynamic)["name"];
  }
}
