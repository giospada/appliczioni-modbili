import 'package:sport_mates/data/activity.dart';
import 'package:flutter/material.dart';
import 'package:sport_mates/config/config.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

List<Activity> historyActivity(
    String user, List<Activity> activities, Position? pos) {
  return activities
      .where((element) =>
          element.time.isBefore(DateTime.now()) &&
          element.participants.contains(user))
      .toList();
}

List<Activity> upcomingFilter(
    String user, List<Activity> activities, Position? pos) {
  return activities
      .where((element) =>
          element.time.isAfter(DateTime.now()) &&
          element.participants.contains(user))
      .toList();
}

Map<String, IconData> sportToIcon = {
  "running": Icons.directions_run,
  "cycling": Icons.directions_bike,
  "swimming": Icons.pool,
  "basketball": Icons.sports_basketball,
  "soccer": Icons.sports_soccer,
  "volleyball": Icons.sports_volleyball,
  "tennis": Icons.sports_tennis,
  "golf": Icons.sports_golf,
  "hiking": Icons.directions_walk,
  "climbing": Icons.terrain,
  "football": Icons.sports_soccer,
};

String displayFormattedDate(DateTime date) {
  return "il ${date.day}/${date.month} alle ${date.hour}:${date.minute}";
}

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

Future<void> scheduleNotification(DateTime scheduledDate) async {
  Config config = Config();

  if (config.notifyBefore == null) {
    return;
  }
  //var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //  'your channel id',
  //  'your channel name',
  //  'your channel description',
  //  importance: Importance.max,
  //  priority: Priority.high,
  //);
  ////var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  //var platformChannelSpecifics = NotificationDetails(
  //    android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

  //await flutterLocalNotificationsPlugin.zonedSchedule(
  //    0,
  //    'Scheduled Notification Title',
  //    'Scheduled Notification Body',
  //    tz.TZDateTime.from(scheduledDate, tz.local),
  //    platformChannelSpecifics,
  //    androidAllowWhileIdle: true,
  //    uiLocalNotificationDateInterpretation:
  //        UILocalNotificationDateInterpretation.absoluteTime);
}

bool isInRatio(PositionActivity p1, PositionActivity p2, double radio) {
  double distance =
      Geolocator.distanceBetween(p1.lat, p1.long, p2.lat, p2.long);
  return radio < distance;
}

String getMeterOrKmDistance(PositionActivity p1, PositionActivity p2) {
  double distance =
      Geolocator.distanceBetween(p1.lat, p1.long, p2.lat, p2.long);
  if (distance < 1000) {
    return "${distance.toStringAsFixed(0)} m";
  } else {
    return "${(distance / 1000).toStringAsFixed(2)} km";
  }
}

Position createSimplePosition(LatLng latLong) {
  return Position(
    latitude: latLong.latitude,
    longitude: latLong.longitude,
    timestamp: DateTime.now(), // Not available
    accuracy: 0.0, // Default to 0 for simplicity
    altitude: 0.0, // Default to 0
    heading: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0, // Not available
    floor: null, // Not available
    isMocked: false, altitudeAccuracy: 0.0,
    headingAccuracy: 0.0, // Default to false
  );
}
