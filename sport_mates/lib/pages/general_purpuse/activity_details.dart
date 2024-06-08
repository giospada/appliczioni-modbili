import 'package:sport_mates/utils.dart';
import 'package:flutter/material.dart';
import 'package:sport_mates/data/activity_data.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart';
import 'package:maps_launcher/maps_launcher.dart';

class ActivityDetailsWidget extends StatelessWidget {
  Activity activityData;
  LatLng position;

  ActivityDetailsWidget(
      {super.key, required this.activityData, required this.position});

  @override
  Widget build(BuildContext context) {
    int restanti =
        (activityData.numberOfPeople - activityData.participants.length);

    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    FlutterMap(
                        options: MapOptions(
                          initialCenter: activityData.position,
                          initialZoom: 13.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.app',
                          ),
                          MarkerLayer(markers: [
                            Marker(
                              width: 80.0,
                              height: 80.0,
                              point: activityData.position,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40,
                                ),
                                onPressed: () {
                                  MapsLauncher.launchCoordinates(
                                      activityData.position.latitude,
                                      activityData.position.longitude);
                                },
                              ),
                            ),
                          ])
                        ]),
                    Container(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Icon(
                                sportToIcon[activityData.attributes.sport],
                                color: Colors.black,
                                size: 40),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Text(
                              textAlign: TextAlign.start,
                              'Descrizione',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              activityData.description,
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Space between items in Row
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Align text to the start of the column
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.access_time),
                                  const SizedBox(width: 15),
                                  Text(
                                    displayFormattedDate(activityData.time),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons
                                      .location_on), // Replace with your icon
                                  const SizedBox(width: 15),
                                  Text(
                                    "${getMeterOrKmDistance(activityData.position, position)} distanza",
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                      Icons.people), // Replace with your icon
                                  const SizedBox(width: 15),
                                  Text(
                                    restanti.toString(),
                                    style: TextStyle(
                                      color: restanti > 5
                                          ? Colors.green
                                          : (restanti > 2
                                              ? Colors.orange
                                              : Colors.red),
                                    ),
                                  ),
                                  Text(
                                      ' posti restanti su ${activityData.numberOfPeople}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Price Column on the right
                        Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .end, // Align price to the end of the column
                          children: [
                            (activityData.attributes.price == 0)
                                ? const Text(
                                    "Gratis",
                                    style: TextStyle(color: Colors.green),
                                  )
                                : Text(
                                    "${activityData.attributes.price}€",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Column(
                        children: [
                          Text(
                            'Partecipanti',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(), // Disables ListView's scrolling
                      itemCount: activityData.participants.length,
                      itemBuilder: (context, index) {
                        var e = activityData.participants[index];
                        return ListTile(
                          leading: FadeInImage.assetNetwork(
                            placeholder: 'assets/images/avatar.png',
                            image:
                                'https://api.dicebear.com/7.x/lorelei/png?seed=$e',
                          ),
                          title: Text(e),
                          trailing: (activityData.creator == e)
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Padding(
                                      padding: EdgeInsets.all(3.0),
                                      child: Text(
                                        'Creatore',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      )))
                              : const SizedBox(),
                        );
                      },
                    ),
                    // Use ListView.builder or a similar approach if you have a long list of items.
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
