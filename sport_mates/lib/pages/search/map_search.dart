import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:sport_mates/data/activity.dart';
import 'package:sport_mates/pages/general_purpuse/activity_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_mates/pages/general_purpuse/map_markers.dart';

class MapSearch extends StatefulWidget {
  LatLng pos;
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
  LatLng pos;
  List<Activity> activities = [];
  double radius;

  _MapSearchState(this.pos, this.activities, this.radius);

  PageController controller = PageController(viewportFraction: 0.8);
  MapController mapController = MapController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MapSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    this.activities = [...widget.activities];
    this.pos = widget.pos;
    this.radius = widget.radius;
    mapController.move(pos, 13);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var marker =
        createMarkers(mapController, activities, pos, radius, (Activity t) {
      controller.animateToPage(activities.indexOf(t),
          duration: Duration(milliseconds: 500), curve: Curves.ease);
      mapController.move(t.position, 15);
    });

    return Stack(
      children: [
        Positioned.fill(
          child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                  initialCenter: pos,
                  initialZoom: 13,
                  onMapReady: () {
                    mapController.mapEventStream.listen((event) {
                      if (event is MapEventMove) {
                        event = event as MapEventMove;
                        setState(() {});
                      }
                      if (event is MapEventScrollWheelZoom) {
                        event = event as MapEventScrollWheelZoom;
                        setState(() {});
                      }
                      if (event is MapEventDoubleTapZoom) {
                        event = event as MapEventDoubleTapZoom;
                        setState(() {});
                      }
                    });
                  }),
              children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    ) as Widget
                  ] +
                  marker),
        ),
        Container(
          height: 150,
          child: PageView.builder(
            itemCount: activities.length,
            controller: controller,
            onPageChanged: (int index) {
              mapController.move(activities[index].position, 15);
              setState(() {});
            },
            itemBuilder: (context, index) {
              return ActivityCardWidget(
                  activityData: activities[index], pos: pos);
            },
          ),
        ),
      ],
    );
  }
}
