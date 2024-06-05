import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_mates/pages/general_purpuse/maps_search.dart';

import 'package:sport_mates/utils.dart';

class PosSelectorWidget extends StatefulWidget {
  LatLng position;

  PosSelectorWidget(this.position);

  @override
  State<PosSelectorWidget> createState() => _PosSelectorWidgetState(position);
}

class _PosSelectorWidgetState extends State<PosSelectorWidget> {
  LatLng position;
  double long = 0, lat = 0;
  MapController mapController = MapController();

  _PosSelectorWidgetState(this.position);

  CancelableOperation? cancelableOperation;

  @override
  void initState() {
    long = position.longitude;
    lat = position.latitude;
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
                      initialCenter:
                          LatLng(position.latitude, position.longitude),
                      initialZoom: 13.0,
                      onMapReady: () {
                        mapController.mapEventStream.listen((event) {
                          if (event is MapEventMove) {
                            event = event;
                            setState(() {
                              lat = event.camera.center.latitude;
                              long = event.camera.center.longitude;
                            });
                          }
                          if (event is MapEventScrollWheelZoom) {
                            event = event;
                            setState(() {
                              lat = event.camera.center.latitude;
                              long = event.camera.center.longitude;
                            });
                          }
                          if (event is MapEventDoubleTapZoom) {
                            event = event;
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
                          child: const Icon(
                            Icons.location_on,
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: MapSearchBar(
                      onSearch: (lat, lon) {
                        mapController.move(
                            LatLng(lat, lon), mapController.camera.zoom);
                      },
                    )),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(color: Colors.white60),
                    child: IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: () async {
                        mapController.move(await determinePosition(), 15);
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
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(LatLng(lat, long));
                    },
                    child: const Text('Scegli questa posizione')),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
