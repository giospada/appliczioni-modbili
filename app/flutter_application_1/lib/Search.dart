import 'package:flutter/material.dart';
import 'package:flutter_application_1/settings.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        actions: [
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (builder) => SettingsPage()));
              })
        ],
      ),
      body: Center(
        child: Text('Search Page'),
      ),
    );
  }
}
