import 'package:flutter/material.dart';
import 'package:flutter_application_1/activity_card.dart';
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
      body: ActivityCardWidget(),
      drawerEnableOpenDragGesture: true,
      bottomNavigationBar: BottomAppBar(
        child: BottomAppBar(
          child: Row(
            children: <Widget>[
              IconButton(
                tooltip: 'Open popup menu',
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  final SnackBar snackBar = SnackBar(
                    content: const Text('Yay! A SnackBar!'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {},
                    ),
                  );

                  // Find the ScaffoldMessenger in the widget tree
                  // and use it to show a SnackBar.
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              ),
              IconButton(
                tooltip: 'Search',
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
              IconButton(
                tooltip: 'Favorite',
                icon: const Icon(Icons.favorite),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
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
