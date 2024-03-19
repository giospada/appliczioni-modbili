import 'package:SportMates/pages/search/Filters.dart';
import 'package:SportMates/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:SportMates/data/activity.dart';
import 'package:SportMates/pages/general_purpuse/activity_card.dart';
import 'package:SportMates/config/config.dart';
import 'package:SportMates/pages/new_activity/new_activity.dart';
import 'package:SportMates/pages/settings/settings.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _loading = true;
  List<Activity> activities = [];
  Position? pos;
  Filters filters = Filters();

  void loadIds() async {
    Map<String, dynamic> params = {};

    if (pos != null) {
      params['lat'] = pos!.latitude.toString();
      params['lon'] = pos!.longitude.toString();
    }

    final req =
        await http.get(Uri.http(Config().host, '/activities/search', params));
    if (req.statusCode != 200) {
      throw Exception('Failed to load ids');
    }
    final ids = json.decode(req.body);
    _loading = false;
    ids.forEach((id) async {
      final activityReq = await http.get(Uri.http(
        Config().host,
        '/activities/$id',
      ));
      if (activityReq.statusCode != 200) {
        throw Exception('Failed to load activity');
      }
      final activity = json.decode(activityReq.body);
      setState(() {
        activities.add(Activity.fromJson(activity));
      });
    });
  }

  Future<void> start() async {
    pos = await determinePosition();
    loadIds();
  }

  @override
  void initState() {
    super.initState();
    start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              child: filters,
            ),
            _loading
                ? Center(child: CircularProgressIndicator())
                : activities.length > 0
                    ? Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: activities.length,
                          itemBuilder: (context, index) {
                            return ActivityCardWidget(
                                activityData: activities[index]);
                          },
                        ),
                      )
                    : Center(child: Text('No activities found')),
          ],
        ),
      ),
      drawerEnableOpenDragGesture: true,
      bottomNavigationBar: BottomAppBar(
        child: BottomAppBar(
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (builder) => SettingsPage()));
                },
              ),
              IconButton(
                icon: Icon(Icons.upcoming),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (builder) => SettingsPage()));
                },
              ),
              IconButton(
                icon: Icon(Icons.history),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (builder) => SettingsPage()));
                },
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (builder) => CreateActivityWidget()));
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }
}
