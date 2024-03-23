import 'package:SportMates/data/activity.dart';
import 'package:SportMates/data/feedback.dart';
import 'package:SportMates/pages/feedback/feedback_list.dart';
import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  final List<Activity> activities;
  final List<FeedbackActivity> feedback;

  const FeedbackPage(
      {super.key, required this.activities, required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Feedback'),
        ),
        body: (feedback.length == 0)
            ? Center(
                child: Text('No feedback'),
              )
            : ListView.builder(
                itemCount: feedback.length,
                itemBuilder: (context, index) {
                  return FeedbackCardWidget(
                    activityData: activities[index],
                    feedbackData: feedback[index],
                  );
                }));
  }
}
