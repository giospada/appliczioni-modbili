import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/auth_provider.dart';
import 'package:flutter_application_1/data/activity.dart';
import 'package:flutter_application_1/config/config.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/pages/loader.dart';
import 'package:provider/provider.dart';

class ActivityDetailsWidget extends StatelessWidget {
  Activity activityData;

  ActivityDetailsWidget({super.key, required this.activityData});

  String token = '';

  Future<http.Response> _tryJoin(int id) async {
    final response = await http.post(
      Uri.parse('${Config().host}/activities/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${token}'
      },
      body:
          json.encode({"activityId": activityData.id, 'username': 'testuser'}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to join activity');
    }
    return response;
  }

  @override
  Widget build(BuildContext context) {
    token = Provider.of<AuthProvider>(context, listen: false).token!;
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Details'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(activityData.description),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(activityData.attributes.sport),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(activityData.attributes.price.toString() + "€"),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(activityData.time.toString()),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(activityData.numberOfPeople.toString()),
          ),
          Expanded(
            child: ListView(
              children: activityData.participants
                  .map((e) => ListTile(
                        leading: FadeInImage.assetNetwork(
                            placeholder: 'assets/images/logo.png',
                            image:
                                'https://api.dicebear.com/7.x/lorelei/png?seed=${e}'),
                        title: Text(e),
                      ))
                  .toList(),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final data = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AsyncLoaderPage(
                      asyncOperation: () async {
                        _tryJoin(activityData.id);
                      },
                    )),
          );
          if (data is Exception) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to join activity')));
          } else {
            Navigator.pop(context);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
