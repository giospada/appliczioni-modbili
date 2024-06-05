import 'package:flutter/material.dart';
import 'package:sport_mates/config/auth_provider.dart';
import 'package:sport_mates/config/config.dart';
import 'package:provider/provider.dart';
import 'package:sport_mates/config/data_provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final username = Provider.of<AuthProvider>(context).getUsername ?? '';
    var notifyBefore = Config().notifyBefore;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
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
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: FadeInImage.assetNetwork(
                        placeholder: 'assets/images/avatar.png',
                        image:
                            'https://api.dicebear.com/7.x/lorelei/png?seed=${username}')),
              ],
            ),
            Text(
              username,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            //Create a dropdown menu to select how much before the event the user wants to be notified
            const Divider(),
            ListTile(
                title: const Text('Notifica prima dell\'evento'),
                trailing: StatefulBuilder(
                  builder: (context, setState) {
                    return DropdownButton<int>(
                      value: notifyBefore,
                      items: [5, 10, 15, 20, 30, 60, null]
                          .map<DropdownMenuItem<int>>((e) =>
                              DropdownMenuItem<int>(
                                value: e,
                                child: Text(e != null ? '$e minuti' : 'mai'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        Config().notifyBefore = value;
                        setState(() {
                          notifyBefore = value;
                        });
                      },
                    );
                  },
                )),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Esci'),
              onTap: () async {
                Provider.of<AuthProvider>(context, listen: false).logout();
                await Provider.of<DataProvider>(context, listen: false)
                    .deleteAllStoredData();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
