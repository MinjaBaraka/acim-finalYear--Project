// ignore_for_file: unrelated_type_equality_checks, avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../global/global.dart';
import '../global/mapkey.dart';
import '../global/progress_dialog.dart';
import '../infoHandler/app_info.dart';
import '../model/directions_model.dart';
import '../model/predicted_places.dart';
import '../pages/admin/main_admin_screen.dart';
import '../requestMethod/request_assistant.dart';

class PlacePredictionTitleDesign extends StatefulWidget {
  const PlacePredictionTitleDesign({super.key, this.predictedPlaces});

  final PredictedPlaces? predictedPlaces;

  @override
  State<PlacePredictionTitleDesign> createState() =>
      _PlacePredictionTitleDesignState();
}

class _PlacePredictionTitleDesignState
    extends State<PlacePredictionTitleDesign> {
//Create a function that will search the specific place with directions

  getPlaceDirectionDetails(String placeId, context) async {
    showDialog(
      context: context,
      builder: (context) => const ProgressDialog(
        message: 'Setting up Drop-Off, Please Wait...',
      ),
    );

    String placeDirectionDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKeys";

    var responseApi =
        await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);

    // print(responseApi);

    Navigator.pop(context);

    if (responseApi == "Error Occured, Failed No Response...") {
      return;
    }

    if (responseApi["status"] == "Ok") {
      Directions directions = Directions();
      directions.locationName = responseApi["result"]["name"];
      directions.locationId = placeId;
      directions.locationLatitude =
          responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongtitude =
          responseApi["result"]["geometry"]["location"]["lng"];

      Provider.of<AppInfo>(context, listen: false)
          .updateDropOffLocationAddress(directions);

      setState(() {
        userDropOffAddress = directions.locationName!;
      });

      // Navigator.pop(context, "ObtainedDropOff");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminScreen(),
        ),
      );

      print("This is your Drop Off Location::  ${directions.locationName}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: ElevatedButton(
        onPressed: () {
          getPlaceDirectionDetails(widget.predictedPlaces!.placeId!, context);
          // print(getPlaceDirectionDetails(
          //     widget.predictedPlaces!.placeId!, context));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              const Icon(
                Icons.add_location,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.predictedPlaces!.mainText!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.predictedPlaces!.secondaryText!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
