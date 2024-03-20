import 'package:flutter/material.dart';
import 'package:SportMates/data/activity.dart';
import 'package:SportMates/pages/general_purpuse/activity_details.dart';
import 'package:SportMates/utils.dart';
import 'package:geolocator/geolocator.dart';

class ActivityCardWidget extends StatelessWidget {
  final Activity activityData;
  final Position? pos;

  const ActivityCardWidget(
      {Key? key, required this.activityData, required this.pos})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int restanti =
        (activityData.numberOfPeople - activityData.participants.length);
    PositionActivity positionActivity =
        PositionActivity(long: pos!.longitude, lat: pos!.latitude);
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
          padding: EdgeInsets.fromLTRB(8, 12, 8, 8),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayFormattedDate(activityData.time),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(activityData.description),
                      ],
                    ),
                  )
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      Text(
                          "${getMeterOrKmDistance(activityData.position, positionActivity)} distanza"),
                      SizedBox(width: 10),
                      (activityData.attributes.price == 0)
                          ? Text(
                              "Gratis",
                              style: TextStyle(color: Colors.green),
                            )
                          : Text(
                              activityData.attributes.price.toString() + "€",
                            ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('restanti '),
                      Text(
                        restanti.toString(),
                        style: TextStyle(
                            color: restanti > 5
                                ? Colors.green
                                : (restanti > 2 ? Colors.orange : Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
