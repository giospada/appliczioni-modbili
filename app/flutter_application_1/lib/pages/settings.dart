import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/auth_provider.dart';
import 'package:flutter_application_1/config/config.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final username = Provider.of<AuthProvider>(context).getUsername ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                    width: double.infinity,
                    height: 120,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: FadeInImage.assetNetwork(
                        placeholder: 'assets/images/logo.png',
                        image:
                            'https://api.dicebear.com/7.x/lorelei/png?seed=${username}')),
              ],
            ),
            Text(
              username,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            //Create a dropdown menu to select how much before the event the user wants to be notified
            Divider(),
            ListTile(
              title: Text('Notify me before the event'),
              trailing: DropdownButton<int>(
                value: Config().notifyBefore,
                items: [5, 10, 15, 20, 30, 60, null]
                    .map<DropdownMenuItem<int>>((e) => DropdownMenuItem<int>(
                          child: Text(e != null ? '$e minutes' : 'Never'),
                          value: e,
                        ))
                    .toList(),
                onChanged: (value) {
                  Config().notifyBefore = value;
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
