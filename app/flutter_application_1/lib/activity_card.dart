import 'package:flutter/material.dart';
import 'package:flutter_application_1/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ActivityCardWidget extends StatelessWidget {
  final Map<String, dynamic>? activityData;

  ActivityCardWidget({Key? key, this.activityData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 10, 8, 8),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.access_time, size: 40),
                ),
                Expanded(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: [Text('prova'), Text('prova')],
                    ),
                    Column(
                      children: [Text('prova'), Text('prova')],
                    ),
                  ],
                ))
              ],
            ),
            Divider(),
            Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. '
                'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. '
                'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.')
          ],
        ),
      ),
    );
  }
}
