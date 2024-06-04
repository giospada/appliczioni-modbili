import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_mates/data/activity.dart';
import 'package:sport_mates/pages/general_purpuse/activity_page.dart';
import 'package:sport_mates/utils.dart';
import 'package:geolocator/geolocator.dart';

class ActivityCardWidget extends StatelessWidget {
  final Activity activityData;
  final LatLng? pos;
  final Function? onReturn;

  const ActivityCardWidget(
      {Key? key, required this.activityData, required this.pos, this.onReturn})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int restanti =
        (activityData.numberOfPeople - activityData.participants.length);

    return InkWell(
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ActivityDetailsPage(
                    activityData: activityData, position: pos!)));
        if (onReturn != null) {
          onReturn!();
        }
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          activityData.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                          "${getMeterOrKmDistance(activityData.position, pos!)} distanza"),
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
