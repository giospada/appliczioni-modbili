import 'package:flutter/material.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

class PlacePickerWidget extends StatefulWidget {
  const PlacePickerWidget({Key? key}) : super(key: key);

  @override
  State<PlacePickerWidget> createState() => _PlacePickerWidgetState();
}

class _PlacePickerWidgetState extends State<PlacePickerWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: OpenStreetMapSearchAndPick(
      buttonTextStyle:
          const TextStyle(fontSize: 18, fontStyle: FontStyle.normal),
      buttonColor: Colors.blue,
      buttonText: 'Set Current Location',
      onPicked: (pickedData) {
        Navigator.pop(context, {
          'lat': pickedData.latLong.latitude,
          'long': pickedData.latLong.longitude,
          'address': pickedData.address,
          'addressName': pickedData.addressName
        });
      },
    ));
  }
}
