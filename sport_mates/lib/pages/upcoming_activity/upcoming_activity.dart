import 'package:latlong2/latlong.dart';
import 'package:sport_mates/data/activity_data.dart';
import 'package:sport_mates/pages/general_purpuse/activity_card.dart';
import 'package:flutter/material.dart';

class UpcoingActivity extends StatelessWidget {
  final List<Activity> activities;
  final LatLng? pos;

  const UpcoingActivity(
      {super.key, required this.activities, required this.pos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Attività in programma'),
        ),
        body: (activities.isEmpty)
            ? const Center(
                child: Text('Nessuna attività trovata'),
              )
            : ListView.builder(
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  return ActivityCardWidget(
                      onReturn: () {
                        Navigator.pop(context);
                      },
                      activityData: activities[index],
                      pos: LatLng(pos!.latitude, pos!.longitude));
                }));
  }
}
