import 'package:SportMates/data/activity.dart';
import 'package:SportMates/data/feedback.dart';
import 'package:SportMates/pages/feedback/feedback.dart';
import 'package:SportMates/pages/feedback/rating_stars.dart';
import 'package:SportMates/utils.dart';
import 'package:flutter/material.dart';

class FeedbackCardWidget extends StatelessWidget {
  final Activity activityData;
  final FeedbackActivity? feedbackData;

  const FeedbackCardWidget({
    Key? key,
    required this.activityData,
    this.feedbackData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(sportToIcon[activityData.attributes.sport]),
        title: Text(displayFormattedDate(activityData.time)),
        subtitle: feedbackData != null
            ? Text(feedbackData!.comment)
            : ElevatedButton(
                child: Text('Add Feedback'),
                onPressed: () {
                  // Navigate to a new screen to add feedback
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddFeedbackScreen(activity: activityData),
                    ),
                  );
                },
              ),
        trailing: feedbackData != null
            ? StarRatingWidget(rating: feedbackData!.rating.toDouble())
            : null,
      ),
    );
  }
}
