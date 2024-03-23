import 'package:flutter/material.dart';
import 'package:SportMates/config/auth_provider.dart';
import 'package:SportMates/config/config.dart';
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
                        placeholder: 'assets/images/avatar.png',
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
                          value: e,
                          child: Text(e != null ? '$e minutes' : 'Never'),
                        ))
                    .toList(),
                onChanged: (value) {
                  Config().notifyBefore = value;
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
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
