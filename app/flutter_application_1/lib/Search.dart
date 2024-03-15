import 'package:flutter/material.dart';
import 'package:flutter_application_1/new_activity.dart';
import 'package:flutter_application_1/settings.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Center(
        child: Text('Search Page'),
      ),
      drawerEnableOpenDragGesture: true,
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
              title: Text(
                'Create',
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CreateActivityWidget()));
              },
              style: ListTileStyle.drawer,
            ),
            ListTile(
              title: Text('Settings'),
              leading: Icon(Icons.settings),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (builder) => SettingsPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
