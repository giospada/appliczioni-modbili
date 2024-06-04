import 'package:provider/provider.dart';
import 'package:sport_mates/config/auth_provider.dart';
import 'package:sport_mates/config/data_provider.dart';
import 'package:sport_mates/data/activity.dart';
import 'package:sport_mates/data/feedback.dart';
import 'package:sport_mates/pages/feedback/feedback_list.dart';
import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthProvider>(context).getUsername;
    var activityData = Provider.of<DataProvider>(context).toApplicationData();

    var activities = activityData.activities
        .where((element) =>
            element.participants.contains(user) &&
            element.time.isBefore(DateTime.now()))
        .toList();
    var feedback = activityData.feedbacks;

    Map<int, FeedbackActivity> feedbackMap =
        Map.fromIterable(feedback, key: (e) => e.activityId, value: (e) => e);

    return Scaffold(
        appBar: AppBar(
          title: Text('Feedback'),
        ),
        body: (activities.length == 0)
            ? Center(
                child: Text('No feedback'),
              )
            : ListView.builder(
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  return FeedbackCardWidget(
                    activityData: activities[index],
                    feedbackData: feedbackMap[activities[index].id],
                  );
                }));
  }
}
