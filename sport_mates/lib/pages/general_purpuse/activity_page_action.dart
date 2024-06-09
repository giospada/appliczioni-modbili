import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sport_mates/provider/data_provider.dart';
import 'package:sport_mates/main.dart';
import 'package:sport_mates/pages/general_purpuse/activity_details.dart';
import 'package:sport_mates/utils.dart';
import 'package:flutter/material.dart';
import 'package:sport_mates/provider/auth_provider.dart';
import 'package:sport_mates/data/activity_data.dart';
import 'package:sport_mates/config/config.dart';
import 'package:http/http.dart' as http;

import 'package:sport_mates/pages/general_purpuse/loader.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

enum _Action { join, leave, delete }

Future<http.Response> leave(String token, int id) async {
  final response = await http.post(
    Uri.https(Config().host, '/activity/$id/leave'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    },
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to join activity');
  }
  return response;
}

Future<http.Response> delete(String token, int id) async {
  final response = await http.delete(
    Uri.https(Config().host, '/activity/$id'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    },
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to join activity');
  }
  return response;
}

Future<http.Response> join(String token, int id) async {
  final response = await http.post(
    Uri.https(Config().host, '/activities/register'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    },
    body: json.encode({"activityId": id, 'username': 'testuser'}),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to join activity');
  }
  return response;
}

class ActivityDetailsPage extends StatelessWidget {
  Activity activityData;
  LatLng position;

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();
    }
  }

  ActivityDetailsPage(
      {super.key, required this.activityData, required this.position});

  String token = '';
  String user = '';

  Map<
      _Action,
      (
        Future<dynamic> Function(String, int),
        void Function(BuildContext, int, String),
        String
      )> azioni = {
    _Action.join: (
      join,
      (context, id, user) {
        Provider.of<DataProvider>(context, listen: false)
            .joinActivity(id, user);
      },
      'prender parte'
    ),
    _Action.leave: (
      leave,
      (context, id, user) {
        Provider.of<DataProvider>(context, listen: false)
            .leaveActivity(id, user);
      },
      'lasciare'
    ),
    _Action.delete: (
      delete,
      (context, id, _) {
        Provider.of<DataProvider>(context, listen: false).deleteActivity(id);
      },
      'eliminare'
    )
  };

  Future<void> asyncRouteOperation(BuildContext context, _Action action) async {
    var azione = azioni[action]!;
    final data = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AsyncLoaderPage(
                asyncOperation: () async =>
                    await azione.$1(token, activityData.id),
              )),
    );

    if (context.mounted) {
      if (data is Exception) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Impossibile ${azione.$3} l\'attività')));
      } else {
        azione.$2(context, activityData.id, user);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    token = Provider.of<AuthProvider>(context, listen: false).token!;
    user = Provider.of<AuthProvider>(context, listen: false).getUsername!;
    final bool isParticipant = activityData.participants.contains(user);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettagli Attività'),
      ),
      body: ActivityDetailsWidget(
        activityData: activityData,
        position: position,
      ),
      persistentFooterButtons: [
        Center(
          child: isParticipant
              ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  (activityData.creator == user)
                      ? OutlinedButton(
                          onPressed: () async {
                            await asyncRouteOperation(context, _Action.delete);
                          },
                          child: const Wrap(
                            children: [
                              Icon(Icons.delete, size: 20),
                              SizedBox(width: 10),
                              Text('Elimina l\'attività'),
                            ],
                          ))
                      : OutlinedButton(
                          onPressed: () async {
                            await asyncRouteOperation(context, _Action.leave);
                          },
                          child: const Wrap(
                            children: [
                              Icon(Icons.exit_to_app, size: 20),
                              SizedBox(width: 10),
                              Text('Lascia l\'attività'),
                            ],
                          )),
                  FutureBuilder(
                    future: getActiveNotification(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox();
                      } else {
                        bool isScheduled = snapshot.data == activityData.id;

                        return StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return isScheduled
                                ? IconButton(
                                    onPressed: () async {
                                      await cancelNotification(activityData.id);
                                      setState(() {
                                        isScheduled = false;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Notifica disabilitata'),
                                        ),
                                      );
                                    },
                                    icon:
                                        const Icon(Icons.notifications_active))
                                : IconButton(
                                    onPressed: () async {
                                      if (Config().notifyBefore == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Le notifiche non sono abilitate nelle impostazioni'),
                                          ),
                                        );
                                      } else {
                                        var time = activityData.time.subtract(
                                            Duration(
                                                minutes:
                                                    Config().notifyBefore!));
                                        await _requestPermissions();
                                        await _isAndroidPermissionGranted();
                                        scheduleNotification(
                                            time,
                                            activityData.id,
                                            "${activityData.attributes.sport} Ti aspetta",
                                            activityData.description);
                                        setState(() {
                                          isScheduled = true;
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('Notifica abilitata'),
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.notification_add));
                          },
                        );
                      }
                    },
                  )
                ])
              : ElevatedButton(
                  onPressed: () async {
                    await asyncRouteOperation(context, _Action.join);
                  },
                  child: const Wrap(
                    children: [
                      Icon(Icons.add, size: 20),
                      SizedBox(width: 10),
                      Text('Prendi parte'),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
