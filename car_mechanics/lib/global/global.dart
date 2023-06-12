import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '../model/all_user_model.dart';
import '../model/car_mechanics_driver_data.dart';

FirebaseAuth firebaseAuth = FirebaseAuth.instance;

User? currentUser;

AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();

UserModal? userModalCurrentInfo;

Position? dirvermechanicsCurrentPosition;

String userDropOffAddress = "";

CarMechanicsDriverData onlineMechanicsData = CarMechanicsDriverData();

String? mechanicsTypeDetails = "";

String? driverMechanicsVehicleType;

StreamSubscription<Position>? streamSubscriptionPosition;

StreamSubscription<Position>? streamSubscriptionMechanicsLivePosition;
