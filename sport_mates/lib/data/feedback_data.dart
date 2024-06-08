class FeedbackActivity {
  String username;
  int activityId;
  int rating;
  String comment;

  FeedbackActivity(
      {required this.username,
      required this.activityId,
      required this.rating,
      required this.comment}) {
    // Add method body here if needed
  }

  factory FeedbackActivity.fromJson(Map<String, dynamic> json) {
    return FeedbackActivity(
      username: json['username'],
      activityId: json['activity_id'],
      rating: json['rating'],
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "activity_id": activityId,
      "rating": rating,
      "comment": comment,
    };
  }
}
