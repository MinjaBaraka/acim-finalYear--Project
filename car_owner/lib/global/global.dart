import 'package:firebase_auth/firebase_auth.dart';

import '../model/all_user_model.dart';
import '../model/car_mechanic.dart';
import '../model/direction_details_info.dart';

FirebaseAuth firebaseAuth = FirebaseAuth.instance;

User? currentUser;

UserModal? userModalCurrentInfo;
CarMechanic? mechanic;

String cloudMessageServerToken =
    "key=AAAA65GYqdw:APA91bHzU5f3BxmTfFxd3Q1I3obLWIkHwTpGLffYe5TCA-b-yNcUxDcyC2cU3aLhP5pTWzwHLjBLcV86cjfrX5B3Tsg9VnxTrBZxJTkDevY9PStcdwUlQOICbAt0m9f8EZr_ULjYhj5p";

List driverMechanicsList = [];

List onlineMechanicsList = [];

String userDropOffAddress = "";

DirectionDetailsInfo? tripDirectionDetailsInfo;

String driverMechanicsDetails = "";
String driverMechanicsName = "";
String driverMechanicsPhone = "";

double countRatingsStars = 0.0;
String titleStarsRating = "";
