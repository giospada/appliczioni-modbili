import 'dart:math';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_mates/data/activity.dart';
import 'package:sport_mates/pages/general_purpuse/map_markers.dart';
import 'package:sport_mates/pages/general_purpuse/maps_search.dart';

import 'package:sport_mates/utils.dart';

class RadiusSelectorWidget extends StatefulWidget {
  LatLng position;
  double radius;
  List<Activity> activities = [];

  RadiusSelectorWidget(this.position, this.radius, this.activities);

  @override
  State<RadiusSelectorWidget> createState() =>
      _RadiusSelectorWidgetState(position, radius, activities);
}

class _RadiusSelectorWidgetState extends State<RadiusSelectorWidget> {
  LatLng center;
  double radius = 1000;
  MapController mapController = MapController();
  List<Activity> activities = [];

  _RadiusSelectorWidgetState(this.center, this.radius, this.activities);

  CancelableOperation? cancelableOperation;

  @override
  void initState() {
    super.initState();
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
                        initialCenter: center,
                        initialZoom: 13.0,
                        onMapReady: () {
                          mapController.mapEventStream.listen((event) {
                            if (event is MapEventMove) {
                              event = event as MapEventMove;
                              setState(() {
                                center = LatLng(event.camera.center.latitude,
                                    event.camera.center.longitude);
                              });
                            }
                            if (event is MapEventScrollWheelZoom) {
                              event = event as MapEventScrollWheelZoom;
                              setState(() {
                                center = LatLng(event.camera.center.latitude,
                                    event.camera.center.longitude);
                              });
                            }
                            if (event is MapEventDoubleTapZoom) {
                              event = event as MapEventDoubleTapZoom;
                              setState(() {
                                center = LatLng(event.camera.center.latitude,
                                    event.camera.center.longitude);
                              });
                            }
                          });
                        }),
                    children: [
                          TileLayer(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          ) as Widget
                        ] +
                        createMarkers(
                            mapController, activities, center, radius, null)),
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: MapSearchBar(
                    onSearch: (lat, long) {
                      mapController.move(
                          LatLng(lat, long), mapController.camera.zoom);
                    },
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(color: Colors.white60),
                    child: IconButton(
                      icon: Icon(Icons.my_location),
                      onPressed: () async {
                        LatLng pos = await determinePosition();
                        mapController.move(pos, mapController.camera.zoom);
                      },
                    ),
                  ),
                ),
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
                      Navigator.of(context).pop({radius, center});
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
