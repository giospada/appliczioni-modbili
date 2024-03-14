import 'package:flutter/material.dart';

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
                //open settings page
              })
        ],
      ),
      body: Center(
        child: Text('Search Page'),
      ),
    );
  }
}
