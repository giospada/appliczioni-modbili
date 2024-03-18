import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/config.dart';
import 'package:flutter_application_1/data/activity.dart';
import 'package:flutter_application_1/pages/activity_details.dart';
import 'package:flutter_application_1/pages/utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ActivityCardWidget extends StatelessWidget {
  final Activity activityData;

  ActivityCardWidget({Key? key, required this.activityData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int restanti =
        (activityData.participants.length - activityData.numberOfPeople);

    return InkWell(
      onTap: () {
        // Material
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ActivityDetailsWidget(activityData: activityData)));
      },
      child: Card(
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
                            'restanti ' + restanti.toString(),
                            style: TextStyle(
                                color: restanti > 5
                                    ? Colors.green
                                    : (restanti > 2
                                        ? Colors.orange
                                        : Colors.red)),
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
      ),
    );
  }
}
