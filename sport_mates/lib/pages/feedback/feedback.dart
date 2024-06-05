import 'package:provider/provider.dart';
import 'package:sport_mates/config/auth_provider.dart';
import 'package:sport_mates/config/config.dart';
import 'package:sport_mates/config/data_provider.dart';
import 'package:sport_mates/data/activity.dart';
import 'package:flutter/material.dart';
import 'package:sport_mates/pages/feedback/rating_stars.dart';
import 'package:http/http.dart' as http;
import 'package:sport_mates/pages/general_purpuse/activity_details.dart';
import 'dart:convert';
import 'package:sport_mates/data/feedback.dart';

import 'package:sport_mates/pages/general_purpuse/loader.dart';

class AddFeedbackScreen extends StatefulWidget {
  final Activity activity;

  AddFeedbackScreen({Key? key, required this.activity}) : super(key: key);

  @override
  _AddFeedbackScreenState createState() => _AddFeedbackScreenState();
}

class _AddFeedbackScreenState extends State<AddFeedbackScreen> {
  AlertDialog createDialog(BuildContext context, auth) {
    String comment = '';
    int rating = 0;
    return AlertDialog(
      title: const Text('Lascia un feedback per l\' attività'),
      content: StatefulBuilder(
        builder: (context, setState) => SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Commento'),
                        onChanged: (value) {
                          setState(() {
                            comment = value;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      StarRatingWidget(
                        rating: rating as double,
                        onRatingChanged: (newRating) {
                          setState(
                            () {
                              rating = newRating as int;
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
            child: Text('Chiudi'),
            onPressed: () {
              Navigator.pop(context);
            }),
        ElevatedButton(
            child: Text('Manda'),
            onPressed: () {
              Navigator.pop(context, (comment, rating));
            }),
      ],
    );
  }

  Future<http.Response> submitFeedback(
      String token, FeedbackActivity feedback) async {
    final response = await http.post(
        Uri.https(Config().host, 'feedback'), // replace with your API URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(feedback.toJson()));

    if (response.statusCode == 200) {
      Provider.of<DataProvider>(context, listen: false).addFeedback(feedback);
      return response;
    } else {
      // If the server did not return a 200 OK response, then throw an exception.
      throw Exception('Impossible inviare il feedback');
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
        title: Text('Aggiungi un ricordo'),
      ),
      body: ActivityDetailsWidget(
        activityData: activity,
        position: pos,
      ),
      persistentFooterButtons: [
        Center(
          child: FilledButton(
              onPressed: () async {
                (String, int)? toSubmit = await showDialog(
                    context: context,
                    builder: (context) => createDialog(context, auth));

                if (toSubmit != null) {
                  final comment = toSubmit.$1;
                  final rating = toSubmit.$2;
                  final data = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AsyncLoaderPage(
                            asyncOperation: () async => await submitFeedback(
                                auth!,
                                FeedbackActivity(
                                  activityId: widget.activity.id,
                                  rating: rating,
                                  comment: comment,
                                  username: 'test',
                                ))),
                      ));
                  if (data is Exception) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Impossibile inviare il feedback')));
                  } else {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text(
                "Aggiungi un Ricordo",
              )),
        )
      ],
    );
  }
}
