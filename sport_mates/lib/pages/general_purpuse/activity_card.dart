import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sport_mates/data/activity_data.dart';
import 'package:sport_mates/pages/general_purpuse/activity_page_action.dart';
import 'package:sport_mates/provider/auth_provider.dart';
import 'package:sport_mates/utils.dart';
import 'package:geolocator/geolocator.dart';

class ActivityCardWidget extends StatelessWidget {
  final Activity activityData;
  final LatLng? pos;
  final Function? onReturn;

  const ActivityCardWidget(
      {super.key,
      required this.activityData,
      required this.pos,
      this.onReturn});

  @override
  Widget build(BuildContext context) {
    int restanti =
        (activityData.numberOfPeople - activityData.participants.length);

    var user = Provider.of<AuthProvider>(context, listen: false).getUsername;

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
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(sportToIcon[activityData.attributes.sport],
                        size: 40),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              displayFormattedDate(activityData.time),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (activityData.participants.contains(user))
                              const Icon(Icons.event_available,
                                  color: Colors.green),
                          ],
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
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      Text(
                          "${getMeterOrKmDistance(activityData.position, pos!)} distanza"),
                      const SizedBox(width: 10),
                      (activityData.attributes.price == 0)
                          ? const Text(
                              "Gratis",
                              style: TextStyle(color: Colors.green),
                            )
                          : Text(
                              "${activityData.attributes.price}€",
                            ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('restanti '),
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
