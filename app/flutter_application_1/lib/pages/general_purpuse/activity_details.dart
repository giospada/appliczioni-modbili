import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:SportMates/config/auth_provider.dart';
import 'package:SportMates/data/activity.dart';
import 'package:SportMates/config/config.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;

import 'package:SportMates/pages/general_purpuse/loader.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:provider/provider.dart';

class ActivityDetailsWidget extends StatelessWidget {
  Activity activityData;

  ActivityDetailsWidget({super.key, required this.activityData});

  String token = '';

  Future<http.Response> _tryJoin(int id) async {
    final response = await http.post(
      Uri.http(Config().host, '/activities/register'),
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

  @override
  Widget build(BuildContext context) {
    token = Provider.of<AuthProvider>(context, listen: false).token!;
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Details'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 300,
            child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(
                      activityData.position.lat, activityData.position.long),
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
                      point: LatLng(activityData.position.lat,
                          activityData.position.long),
                      child: IconButton(
                        icon: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                        onPressed: () {
                          MapsLauncher.launchCoordinates(
                              activityData.position.lat,
                              activityData.position.long);
                        },
                      ),
                    ),
                  ])
                ]),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(activityData.description),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(activityData.attributes.sport),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(activityData.attributes.price.toString() + "€"),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(activityData.time.toString()),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(activityData.numberOfPeople.toString()),
          ),
          Expanded(
            child: ListView(
              children: activityData.participants
                  .map((e) => ListTile(
                        leading: FadeInImage.assetNetwork(
                            placeholder: 'assets/images/avatar.png',
                            image:
                                'https://api.dicebear.com/7.x/lorelei/png?seed=${e}'),
                        title: Text(e),
                      ))
                  .toList(),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final data = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AsyncLoaderPage(
                      asyncOperation: () async {
                        _tryJoin(activityData.id);
                      },
                    )),
          );
          if (data is Exception) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to join activity')));
          } else {
            Navigator.pop(context);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
