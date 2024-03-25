import 'package:sport_mates/data/activity.dart';
import 'package:sport_mates/data/feedback.dart';
import 'package:sport_mates/pages/feedback/feedback_list.dart';
import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  final List<Activity> activities;
  final List<FeedbackActivity> feedback;

  const FeedbackPage(
      {super.key, required this.activities, required this.feedback});

  @override
  Widget build(BuildContext context) {
    //create a set of the activity that has
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
