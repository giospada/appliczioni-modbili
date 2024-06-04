import 'package:sport_mates/data/activity.dart';
import 'package:sport_mates/data/feedback.dart';
import 'package:sport_mates/pages/feedback/feedback.dart';
import 'package:sport_mates/pages/feedback/rating_stars.dart';
import 'package:sport_mates/utils.dart';
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
          trailing: feedbackData != null
              ? null
              : IconButton(
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
                  icon: Icon(Icons.add)),
          subtitle: feedbackData != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(feedbackData!.comment),
                      StarRatingWidget(rating: feedbackData!.rating.toDouble())
                    ],
                  ),
                )
              : null),
    );
  }
}
