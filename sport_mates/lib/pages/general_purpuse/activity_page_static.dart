import 'package:provider/provider.dart';
import 'package:sport_mates/pages/general_purpuse/activity_details.dart';
import 'package:flutter/material.dart';
import 'package:sport_mates/data/activity_data.dart';
import 'package:sport_mates/provider/data_provider.dart';

class ActivityDetailsPageStatic extends StatelessWidget {
  final Activity activityData;
  ActivityDetailsPageStatic({super.key, required this.activityData});

  @override
  Widget build(BuildContext context) {
    var position = Provider.of<DataProvider>(context, listen: false).lastPos;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettagli Attività'),
      ),
      body: ActivityDetailsWidget(
        activityData: activityData,
        position: position,
      ),
    );
  }
}
