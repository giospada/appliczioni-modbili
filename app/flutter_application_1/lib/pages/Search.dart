import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_1/data/activity.dart';
import 'package:flutter_application_1/pages/activity_card.dart';
import 'package:flutter_application_1/config/config.dart';
import 'package:flutter_application_1/pages/new_activity.dart';
import 'package:flutter_application_1/pages/settings.dart';
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

  void loadIds() async {
    final req = await http.get(Uri.parse('${Config().host}/activities/search'));
    if (req.statusCode != 200) {
      throw Exception('Failed to load ids');
    }
    final ids = json.decode(req.body);
    _loading = false;
    ids.forEach((id) async {
      final activityReq =
          await http.get(Uri.parse('${Config().host}/activities/$id'));
      if (activityReq.statusCode != 200) {
        throw Exception('Failed to load activity');
      }
      final activity = json.decode(activityReq.body);
      setState(() {
        activities.add(Activity.fromJson(activity));
      });
    });
  }

  @override
  void initState() {
    super.initState();
    loadIds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              child: Filters(),
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

class ActivityCard {}

class Filters extends StatefulWidget {
  const Filters({super.key});

  @override
  State<Filters> createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  Map<String, String> filters = {};
  final ScrollController _scrollController = ScrollController();
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget filterToChip(String filterName, String filterValue) {
    return Chip(
      label: Text(filterValue),
      onDeleted: () {
        setState(() {
          filters.remove(filterName);
        });
      },
    );
  }

  void filterDialog() {}

  @override
  Widget build(BuildContext context) {
    List<Widget> filterChips = [];
    filterChips.add(ActionChip(
      label: Text('Filter'),
      avatar: Icon(Icons.filter),
      onPressed: () {
        setState(() {
          int i = Random().nextInt(100);
          filters['filter ${i}'] = 'filter ${i}';
        });
      },
    ));
    for (var filter in filters.entries) {
      filterChips.add(filterToChip(filter.key, filter.value));
    }
    return Container(
      height: 50,
      width: double.infinity,
      child: Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        child: ListView(
          controller: _scrollController,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: filterChips,
        ),
      ),
    );
  }
}
