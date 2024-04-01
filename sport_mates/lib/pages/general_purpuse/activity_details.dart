import 'dart:convert';

import 'package:sport_mates/utils.dart';
import 'package:flutter/material.dart';
import 'package:sport_mates/config/auth_provider.dart';
import 'package:sport_mates/data/activity.dart';
import 'package:sport_mates/config/config.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:sport_mates/pages/general_purpuse/loader.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:provider/provider.dart';

class ActivityDetailsWidget extends StatelessWidget {
  Activity activityData;
  LatLng position;

  ActivityDetailsWidget(
      {super.key, required this.activityData, required this.position});

  String token = '';

  Future<http.Response> leave(int id) async {
    final response = await http.post(
      Uri.https(Config().host, '/activity/$id/leave'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${token}'
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to join activity');
    }
    return response;
  }

  Future<http.Response> delete(int id) async {
    final response = await http.delete(
      Uri.https(Config().host, '/activity/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${token}'
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to join activity');
    }
    return response;
  }

  Future<http.Response> join(int id) async {
    final response = await http.post(
      Uri.https(Config().host, '/activities/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${token}'
      },
      body:
          json.encode({"activityId": activityData.id, 'username': 'testuser'}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to join activity');
    }
    return response;
  }

  Future<void> asyncRouteOperation(
      BuildContext context, Future<dynamic> Function() asyncOperation) async {
    final data = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AsyncLoaderPage(
                asyncOperation: asyncOperation,
              )),
    );
    if (data is Exception) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to join activity')));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    token = Provider.of<AuthProvider>(context, listen: false).token!;
    final String user =
        Provider.of<AuthProvider>(context, listen: false).getUsername!;
    final bool isParticipant = activityData.participants.contains(user);

    int restanti =
        (activityData.numberOfPeople - activityData.participants.length);
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Details'),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
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
                                  icon: Icon(
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
                  padding: EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Container(
                          width: double.infinity,
                          child: Column(
                            children: [
                              Text(
                                textAlign: TextAlign.start,
                                'Description',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
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
                                    Icon(Icons.access_time),
                                    SizedBox(width: 15),
                                    Text(
                                      displayFormattedDate(activityData.time),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons
                                        .location_on), // Replace with your icon
                                    SizedBox(width: 15),
                                    Text(
                                      "${getMeterOrKmDistance(activityData.position, position)} distanza",
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                        Icons.people), // Replace with your icon
                                    SizedBox(width: 15),
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
                                  ? Text(
                                      "Gratis",
                                      style: TextStyle(color: Colors.green),
                                    )
                                  : Text(
                                      "${activityData.attributes.price}€",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ],
                          ),
                        ],
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Column(
                          children: [
                            Text(
                              'Participants',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics:
                            NeverScrollableScrollPhysics(), // Disables ListView's scrolling
                        itemCount: activityData.participants.length,
                        itemBuilder: (context, index) {
                          var e = activityData.participants[index];
                          return ListTile(
                            leading: FadeInImage.assetNetwork(
                              placeholder: 'assets/images/avatar.png',
                              image:
                                  'https://api.dicebear.com/7.x/lorelei/png?seed=${e}',
                            ),
                            title: Text(e),
                            trailing: (activityData.creator == e)
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Text(
                                          'Creator',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        )))
                                : SizedBox(),
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
      ),
      persistentFooterButtons: [
        Center(
          child: (activityData.creator == user)
              ? OutlinedButton(
                  onPressed: () async {
                    await asyncRouteOperation(
                        context, () async => await delete(activityData.id));
                  },
                  child: Wrap(
                    children: [
                      Icon(Icons.delete, size: 20),
                      SizedBox(width: 10),
                      Text('Delete Activity'),
                    ],
                  ))
              : isParticipant
                  ? OutlinedButton(
                      onPressed: () async {
                        await asyncRouteOperation(
                            context, () async => await leave(activityData.id));
                      },
                      child: Wrap(
                        children: [
                          Icon(Icons.exit_to_app, size: 20),
                          SizedBox(width: 10),
                          Text('Leave Activity'),
                        ],
                      ))
                  : ElevatedButton(
                      onPressed: () async {
                        await asyncRouteOperation(
                            context, () async => await join(activityData.id));
                      },
                      child: Wrap(
                        children: [
                          Icon(Icons.add, size: 20),
                          SizedBox(width: 10),
                          Text('Join Activity'),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }
}
