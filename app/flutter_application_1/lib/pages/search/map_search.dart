import 'package:SportMates/data/activity.dart';
import 'package:SportMates/pages/general_purpuse/activity_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

class MapSearch extends StatefulWidget {
  Position pos;
  List<Activity> activities = [];
  double radius;

  MapSearch(
      {super.key,
      required this.pos,
      required this.activities,
      required this.radius});

  @override
  State<MapSearch> createState() => _MapSearchState(pos, activities, radius);
}

class _MapSearchState extends State<MapSearch> {
  Position pos;
  List<Activity> activities = [];
  MapController mapController = MapController();
  double radius;

  _MapSearchState(this.pos, this.activities, this.radius);

  double long = 0, lat = 0;
  int currentSelected = 0;

  @override
  void initState() {
    super.initState();
    long = pos.longitude;
    lat = pos.latitude;
    currentSelected = 0;
  }

  PageController controller = PageController(viewportFraction: 0.8);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = activities.asMap().entries.map((entry) {
      int index = entry.key;
      Activity activity = entry.value;
      return Marker(
        width: 30.0,
        height: 30.0,
        point: LatLng(activity.position.lat, activity.position.long),
        child: IconButton(
          icon: Icon(
            Icons.circle,
            size: 20,
          ),
          onPressed: () {
            mapController.move(
              LatLng(activity.position.lat, activity.position.long),
              15,
            );
            setState(() {
              controller.jumpToPage(index);
            });
          },
        ),
      );
    }).toList();

    markers.add(Marker(
      width: 80.0,
      height: 80.0,
      point: LatLng(pos.latitude, pos.longitude),
      child: Icon(
        Icons.location_pin,
        size: 30,
      ),
    ));
    return Expanded(
        child: Stack(
      children: [
        Expanded(
          child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(lat, long),
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                ),
                MarkerLayer(markers: markers),
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
              ]),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          height: 150,
          child: PageView.builder(
            itemCount: activities.length,
            controller: controller,
            onPageChanged: (int index) {
              setState(() {
                currentSelected = index;
                mapController.move(
                  LatLng(activities[index].position.lat,
                      activities[index].position.long),
                  15,
                );
              });
            },
            itemBuilder: (context, index) {
              return ActivityCardWidget(
                  activityData: activities[index], pos: pos);
            },
          ),
        ),
      ],
    ));
  }
}
