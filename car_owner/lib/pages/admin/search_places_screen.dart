// ignore_for_file: unused_local_variable, avoid_print
import 'package:flutter/material.dart';

import '../../global/mapkey.dart';
import '../../model/predicted_places.dart';
import '../../requestMethod/request_assistant.dart';
import '../../widget/place_prediction.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({super.key});

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  List<PredictedPlaces> placePredictedList = [];

  findPlaceAutoCompleteSearch(String inputText) async {
    if (inputText.length > 1) {
      String urlAutoCompleteSearch =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKeys&components=country:TZ";

      var responseAutocompleteSearch =
          await RequestAssistant.receiveRequest(urlAutoCompleteSearch);

      if (responseAutocompleteSearch ==
          "Error Occurred, Failed No Response...") {
        print(responseAutocompleteSearch);
        return;
      }

      if (responseAutocompleteSearch["status"] == "OK") {
        var placePredictions = responseAutocompleteSearch["predictions"];

        var placePredictionsList = (placePredictions as List?)
            ?.map((jsonData) => PredictedPlaces.fromJson(jsonData))
            .toList();

        setState(() {
          // placePredictedList = placePredictionsList ?? [];
          placePredictedList = placePredictionsList!;
        });
      } else {
        // Handle the case when the status is not OK
        print(
            "Autocomplete API error: ${responseAutocompleteSearch['status']}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),
            title: const Text("Search and dropOff Location"),
            elevation: 0.0,
          ),
          body: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.adjust_sharp,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 18),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextField(
                                onChanged: (value) {
                                  findPlaceAutoCompleteSearch(value);
                                },
                                cursorColor: Colors.black,
                                decoration: const InputDecoration(
                                  hintText: "Search Location here....",
                                  fillColor: Colors.grey,
                                  filled: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 11, top: 8, bottom: 8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              (placePredictedList.isNotEmpty)
                  ? Expanded(
                      child: ListView.separated(
                        itemBuilder: (BuildContext context, index) {
                          return PlacePredictionTitleDesign(
                            predictedPlaces: placePredictedList[index],
                          );
                        },
                        physics: const ClampingScrollPhysics(),
                        separatorBuilder: (context, index) {
                          return const Divider(
                            height: 0,
                            color: Colors.white,
                            thickness: 0,
                          );
                        },
                        itemCount: placePredictedList.length,
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}


// findPlaceAutoCompleteSearch(String inputText) async {
//   if (inputText.length > 1) {
//     String urlAutoCompleteSearch =
//         "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKeys&components=country:TZ";

//     var responseAutocompleteSearch =
//         await RequestAssistant.receiveRequest(urlAutoCompleteSearch);

//     if (responseAutocompleteSearch == "Error Occured, Failed No Response...") {
//       return;
//     }

//     if (responseAutocompleteSearch["status"] == "Ok") {
//       var placePredictions = responseAutocompleteSearch["predictions"];

//       var placePredictionsList = (placePredictions as List)
//           .map((jsonData) => PredictedPlaces.fromJson(jsonData))
//           .toList();

//       setState(() {
//         placePredictedList = placePredictionsList;
//       });
//     }
//   }
// }
