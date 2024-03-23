import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

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

  @override
  void initState() {
    long = position.longitude;
    lat = position.latitude;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Expanded(
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
                initialCenter: LatLng(position.latitude, position.longitude),
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
                    label:
                        radius >= 1000 ? '${radius / 1000} km' : '${radius} m',
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
    ));
  }
}
