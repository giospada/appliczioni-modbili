import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/auth_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final username = Provider.of<AuthProvider>(context).getUsername ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
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
    );
  }
}
