import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sport_mates/data/restartable_task.dart';

class RadiusSelectorWidget extends StatefulWidget {
  Position position;
  double radius;

  RadiusSelectorWidget(this.position, this.radius);

  @override
  State<RadiusSelectorWidget> createState() =>
      _RadiusSelectorWidgetState(position, radius);
}

class _RadiusSelectorWidgetState extends State<RadiusSelectorWidget> {
  Position position;
  double long = 0, lat = 0;
  double radius = 1000;
  MapController mapController = MapController();

  _RadiusSelectorWidgetState(this.position, this.radius);

  var taskManager = RestartableAsyncTask<dynamic>();

  @override
  void initState() {
    long = position.longitude;
    lat = position.latitude;
    super.initState();
  }

  Future<dynamic> _search(controller) async {
    await Future.delayed(Duration(seconds: 1));
    final response = await http.get(
      Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${controller.text}&format=json&polygon_geojson=1&addressdetails=1'),
    );

    if (response.statusCode == 200) {
      List<dynamic> suggestions = jsonDecode(response.body);

      return suggestions;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                      initialCenter:
                          LatLng(position.latitude, position.longitude),
                      initialZoom: 13.0,
                      onMapReady: () {
                        mapController.mapEventStream.listen((event) {
                          if (event is MapEventMove) {
                            event = event as MapEventMove;
                            setState(() {
                              lat = event.camera.center.latitude;
                              long = event.camera.center.longitude;
                            });
                          }
                          if (event is MapEventScrollWheelZoom) {
                            event = event as MapEventScrollWheelZoom;
                            setState(() {
                              lat = event.camera.center.latitude;
                              long = event.camera.center.longitude;
                            });
                          }
                          if (event is MapEventDoubleTapZoom) {
                            event = event as MapEventDoubleTapZoom;
                            setState(() {
                              lat = event.camera.center.latitude;
                              long = event.camera.center.longitude;
                            });
                          }
                        });
                      }),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: LatLng(lat, long),
                          child: Container(
                            child: Icon(
                              Icons.location_on,
                              size: 50,
                            ),
                          ),
                        ),
                      ],
                    ),
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: LatLng(lat, long),
                          radius: radius,
                          useRadiusInMeter: true,
                          borderColor: Color.fromRGBO(8, 8, 8, 0.719),
                          borderStrokeWidth: 1.0,
                          color: Color.fromRGBO(146, 146, 146, 0.216),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  child: SearchAnchor(
                      suggestionsBuilder: (context, controller) async {
                    if (controller.text.isEmpty) {
                      return [];
                    }
                    var suggestions = await taskManager
                        .run(() async => await _search(controller));

                    if (suggestions.isEmpty) {
                      return [Text('No results found')];
                    }
                    return suggestions.map((suggestion) {
                      return ListTile(
                        title: Text(suggestion['display_name']),
                        leading: Text('${controller.text}📍'),
                        onTap: () {
                          double lat = double.parse(suggestion['lat']);
                          double lon = double.parse(suggestion['lon']);
                          mapController.move(
                              LatLng(lat, lon), mapController.camera.zoom);
                          Navigator.of(context).pop();
                        },
                      );
                    }).toList();
                  }, builder:
                          (BuildContext context, SearchController controller) {
                    return SearchBar(
                      onTap: () {
                        controller.openView();
                      },
                      onChanged: (_) {
                        controller.openView();
                      },
                    );
                  }),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Radius '),
                    Slider(
                      value: radius,
                      min: 500,
                      max: 5000,
                      label: radius >= 1000
                          ? '${radius / 1000} km'
                          : '${radius} m',
                      onChanged: (value) {
                        setState(() {
                          radius = value;
                        });
                      },
                    )
                  ],
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop({radius, LatLng(lat, long)});
                    },
                    child: const Text('Choose')),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
