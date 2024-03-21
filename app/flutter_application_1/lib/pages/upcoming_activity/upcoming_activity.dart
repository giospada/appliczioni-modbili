import 'package:SportMates/config/auth_provider.dart';
import 'package:SportMates/data/activity.dart';
import 'package:SportMates/pages/general_purpuse/activity_card.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class UpcoingActivity extends StatelessWidget {
  final List<Activity> activities;
  final Position? pos;

  const UpcoingActivity(
      {super.key, required this.activities, required this.pos});

  @override
  Widget build(BuildContext context) {
    //get user from provider
    final user = Provider.of<AuthProvider>(context).getUsername!;
    return Scaffold(
        appBar: AppBar(
          title: Text('Upcoming Activity'),
        ),
        body: (activities.length == 0)
            ? Center(
                child: Text('No upcoming activity'),
              )
            : ListView.builder(
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  return ActivityCardWidget(
                      activityData: activities[index], pos: pos);
                }));
  }
}
