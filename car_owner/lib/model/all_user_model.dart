import 'package:firebase_database/firebase_database.dart';

class UserModal {
  String? name;
  String? id;
  String? phone;
  String? email;
  String? role;

  UserModal({
    this.email,
    this.id,
    this.name,
    this.phone,
    this.role,
  });

  UserModal.fromSnapshot(DataSnapshot userSnapshot) {
    phone = (userSnapshot.value as dynamic)["phone"];
    name = (userSnapshot.value as dynamic)["name"];
    id = userSnapshot.key;
    email = (userSnapshot.value as dynamic)["email"];
    role = (userSnapshot.value as dynamic)["role"];
  }
}
