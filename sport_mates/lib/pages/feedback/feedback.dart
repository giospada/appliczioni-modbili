import 'package:provider/provider.dart';
import 'package:sport_mates/config/auth_provider.dart';
import 'package:sport_mates/config/config.dart';
import 'package:sport_mates/data/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sport_mates/pages/feedback/rating_stars.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sport_mates/pages/general_purpuse/loader.dart';

class AddFeedbackScreen extends StatefulWidget {
  final Activity activity;

  AddFeedbackScreen({Key? key, required this.activity}) : super(key: key);

  @override
  _AddFeedbackScreenState createState() => _AddFeedbackScreenState();
}

class _AddFeedbackScreenState extends State<AddFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  String _comment = '';
  int _rating = 0;

  Future<http.Response> submitFeedback(String token, String username,
      int activityId, int rating, String comment) async {
    final response = await http.post(
        Uri.https(Config().host, 'feedback'), // replace with your API URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(<String, dynamic>{
          'username': username,
          'activity_id': activityId,
          'rating': rating,
          'comment': comment,
        }));

    if (response.statusCode == 200) {
      return response;
    } else {
      // If the server did not return a 200 OK response, then throw an exception.
      throw Exception('Failed to submit feedback');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context).token;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Feedback'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(15, 8, 15, 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Comment'),
                  onSaved: (value) {
                    setState(() {
                      _comment = value ?? '';
                    });
                  },
                ),
                StarRatingWidget(
                  rating: _rating as double,
                  onRatingChanged: (newRating) {
                    setState(
                      () {
                        _rating = newRating as int;
                      },
                    );
                  },
                ),
                ElevatedButton(
                    child: Text('Submit'),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final data = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AsyncLoaderPage(
                                asyncOperation: () async =>
                                    await submitFeedback(auth!, 'test',
                                        widget.activity.id, _rating, _comment),
                              ),
                            ));
                        if (data is Exception) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Failed to join activity')));
                        } else {
                          Navigator.pop(context);
                        }
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
