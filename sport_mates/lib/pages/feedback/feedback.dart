import 'package:draggable_bottom_sheet/draggable_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:sport_mates/config/auth_provider.dart';
import 'package:sport_mates/config/config.dart';
import 'package:sport_mates/config/data_provider.dart';
import 'package:sport_mates/data/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sport_mates/pages/feedback/rating_stars.dart';
import 'package:http/http.dart' as http;
import 'package:sport_mates/pages/general_purpuse/activity_details.dart';
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
    final _data = Provider.of<DataProvider>(context, listen: false);
    final activity = _data.activities
        .firstWhere((element) => element.id == widget.activity.id);
    final pos = _data.lastPos;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Feedback'),
      ),
      body: DraggableBottomSheet(
        minExtent: 200,
        useSafeArea: false,
        curve: Curves.easeIn,
        previewWidget: _previewWidget(),
        expandedWidget: _expandedWidget(auth),
        duration: const Duration(milliseconds: 10),
        maxExtent: MediaQuery.of(context).size.height * 0.8,
        backgroundWidget: ActivityDetailsWidget(
          activityData: activity,
          position: pos,
        ),
        onDragging: (_) {},
      ),
    );
  }

  Widget _previewWidget() {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: Column(children: <Widget>[
          Container(
            width: 40,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Drag Me',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]));
  }

  Widget _expandedWidget(auth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        children: <Widget>[
          Icon(Icons.keyboard_arrow_down,
              size: 30, color: Theme.of(context).dividerColor),
          const SizedBox(height: 8),
          Padding(
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
                                      await submitFeedback(
                                          auth!,
                                          'test',
                                          widget.activity.id,
                                          _rating,
                                          _comment),
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
        ],
      ),
    );
  }
}
