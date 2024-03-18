import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/config.dart';
import 'package:flutter_application_1/data/activity.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ActivityCardWidget extends StatelessWidget {
  final Activity activityData;

  ActivityCardWidget({Key? key, required this.activityData}) : super(key: key);

  Map<String, IconData> sportToIcon = {
    "running": Icons.directions_run,
    "cycling": Icons.directions_bike,
    "swimming": Icons.pool,
    "basketball": Icons.sports_basketball,
    "soccer": Icons.sports_soccer,
    "volleyball": Icons.sports_volleyball,
    "tennis": Icons.sports_tennis,
    "golf": Icons.sports_golf,
    "hiking": Icons.directions_walk,
    "climbing": Icons.terrain,
    "football": Icons.sports_soccer,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 10, 8, 8),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(sportToIcon[activityData.attributes.sport],
                      size: 40),
                ),
                Expanded(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: [
                        Text(
                          "partecipano " +
                              activityData.numberOfPeople.toString(),
                        ),
                        Text(activityData.time.toString())
                      ],
                    ),
                    Column(
                      children: [
                        Text("30 km"),
                        Text(activityData.attributes.price.toString() + "€")
                      ],
                    ),
                  ],
                ))
              ],
            ),
            Divider(),
            Text(activityData.description)
          ],
        ),
      ),
    );
  }
}
