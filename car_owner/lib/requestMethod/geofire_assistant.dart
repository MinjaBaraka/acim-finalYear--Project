import 'package:car_onwer/model/active_nearby_available_mechanics.dart';

class GeofireAssistant {
  static List<ActiveNearByAvailableMechanics>
      activeNearByAvailableMechanicslist = [];

  static void deleteOfflineMechanicsFromList(String mechanicId) {
    int indexNumber = activeNearByAvailableMechanicslist
        .indexWhere((element) => element.mechanicsId == mechanicId);

    activeNearByAvailableMechanicslist.removeAt(indexNumber);
  }

  static void updateActiveNearByAvailableMechanicsLocation(
      ActiveNearByAvailableMechanics mechanicsWhoMove) {
    int indexNumber = activeNearByAvailableMechanicslist.indexWhere(
        (element) => element.mechanicsId == mechanicsWhoMove.mechanicsId);

    activeNearByAvailableMechanicslist[indexNumber].locationLatitude =
        mechanicsWhoMove.locationLatitude;

    activeNearByAvailableMechanicslist[indexNumber].locationLongitude =
        mechanicsWhoMove.locationLongitude;
  }
}
