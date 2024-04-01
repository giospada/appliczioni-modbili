import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_mates/data/activity.dart';

final double ICON_SIZE = 20;
final double ICON_PADDING = 10;

class Clusters {
  List<Activity> activities = [];
  Point<double> center = Point(0, 0);
  double radius = 0;

  bool isInside(Point<double> point) {
    return pow(center.x - point.x, 2) + pow(center.y - point.y, 2) <
        pow(radius, 2);
  }

  Clusters(this.activities, this.center, this.radius);
}

List<Clusters> _createClusters(List<Activity> activities, LatLngBounds bounds,
    Bounds<double> pixelBounds, MapController mapController) {
  List<Clusters> clusters = [];
  for (Activity cur in activities) {
    Point<double> point = mapController.camera.project(cur.position);
    if (bounds.contains(cur.position)) {
      bool found = false;
      for (Clusters cluster in clusters) {
        if (cluster.isInside(point)) {
          cluster.activities.add(cur);
          found = true;
          break;
        }
      }
      if (!found) {
        clusters.add(Clusters([cur], point, ICON_PADDING + ICON_SIZE / 2));
      }
    }
  }
  return clusters;
}

Marker _createMarker(Activity activity, Function? onTap) {
  return Marker(
    width: ICON_SIZE + ICON_PADDING,
    height: ICON_SIZE + ICON_PADDING,
    point: activity.position,
    child: Center(
      child: (onTap != null)
          ? IconButton(
              onPressed: () => onTap(activity.position),
              icon: Icon(
                Icons.circle,
                size: ICON_SIZE,
              ),
            )
          : Icon(
              Icons.circle,
              size: ICON_SIZE,
            ),
    ),
  );
}

List<Widget> createMarkers(
    MapController mapController,
    List<Activity> activities,
    LatLng center,
    double radius,
    Function(LatLng)? onTap) {
  List<Marker> markers = [];

  try {
    var bounds = mapController.camera.visibleBounds;
    final display_activities = activities
        .where((element) => bounds.contains(element.position))
        .toList();
    mapController.camera.pixelBoundsAtZoom(mapController.camera.zoom);
    markers = _createClusters(display_activities, bounds,
            mapController.camera.pixelBounds, mapController)
        .map((cluster) => Marker(
              width: ICON_SIZE + ICON_PADDING,
              height: ICON_SIZE + ICON_PADDING,
              point: mapController.camera.unproject(cluster.center),
              child: (cluster.activities.length > 1)
                  ? Container(
                      height: ICON_SIZE,
                      width: ICON_SIZE,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          cluster.activities.length.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ))
                  : Icon(
                      Icons.circle,
                      size: ICON_SIZE,
                    ),
            ))
        .toList();
  } catch (e) {
    print('Error $e');
    markers = activities.map((e) => _createMarker(e, onTap)).toList();
  }

  return [
    MarkerLayer(
        markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: center,
                child: Container(
                  child: Icon(
                    Icons.location_on,
                    size: 50,
                  ),
                ),
              ),
            ] +
            markers),
    CircleLayer(
      circles: [
        CircleMarker(
          point: center,
          radius: radius,
          useRadiusInMeter: true,
          borderColor: Color.fromRGBO(8, 8, 8, 0.719),
          borderStrokeWidth: 1.0,
          color: Color.fromRGBO(146, 146, 146, 0.216),
        ),
      ],
    ),
  ];
}
