import 'package:SportMates/pages/search/Filters.dart';
import 'package:SportMates/pages/search/choose_radius.dart';
import 'package:SportMates/pages/search/filter_dialog.dart';
import 'package:SportMates/pages/search/map_search.dart';
import 'package:SportMates/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:SportMates/data/activity.dart';
import 'package:SportMates/pages/general_purpuse/activity_card.dart';
import 'package:SportMates/config/config.dart';
import 'package:SportMates/pages/new_activity/new_activity.dart';
import 'package:SportMates/pages/settings/settings.dart';
import 'package:geolocator/geolocator.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

enum ViewState { map, list }

class _SearchPageState extends State<SearchPage> {
  bool _loading = true;
  List<Activity> activities = [];
  List<Activity> display_activities = [];
  Position? pos;
  double radius = 5000;
  Map<String, dynamic> filters = {};

  double maxPrice = 0;
  bool price = false;
  String selectedSport = Config().nullSport;

  ViewState viewState = ViewState.list;

  void displayFilters(BuildContext context) async {
    var data = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogFilter();
      },
    );
    price = data.elementAt(0);
    selectedSport = data.elementAt(1);
    maxPrice = data.elementAt(2);
    filter();
  }

  void loadIds() async {
    final req = await http.get(Uri.http(Config().host, '/activities/search'));
    if (req.statusCode != 200) {
      throw Exception('Failed to load ids');
    }
    final ids = json.decode(req.body);

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
        _loading = false;
        activities.add(Activity.fromJson(activity));
      });
      filter();
    });
  }

  void filter() {
    setState(() {
      display_activities = activities.where((element) {
        if (price) {
          if (element.attributes.price > maxPrice) {
            return false;
          }
        }
        // if (isInRatio(
        //     element.position,
        //     PositionActivity(long: pos!.longitude, lat: pos!.latitude),
        //     radius)) {
        //   return false;
        // }
        if (selectedSport != Config().nullSport) {
          if (element.attributes.sport != selectedSport) {
            return false;
          }
        }
        if (DateTime.now().isAfter(element.time)) {
          return false;
        }
        return true;
      }).toList();
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
    List<Widget> filterChips = [];

    if (price) {
      filterChips.add(Chip(
        label: Text('Prezzo Massimo $maxPrice €'),
        avatar: Icon(Icons.filter),
        onDeleted: () {
          setState(() {
            price = false;
            maxPrice = 0;
          });
        },
      ));
    }
    if (selectedSport != Config().nullSport) {
      filterChips.add(Chip(
        label: Text('Sport: $selectedSport'),
        avatar: Icon(Icons.filter),
        onDeleted: () {
          setState(() {
            selectedSport = Config().nullSport;
          });
        },
      ));
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SegmentedButton<ViewState>(
                  segments: const [
                    ButtonSegment<ViewState>(
                        value: ViewState.list,
                        label: Text('list'),
                        icon: Icon(Icons.list)),
                    ButtonSegment<ViewState>(
                        value: ViewState.map,
                        label: Text('Map'),
                        icon: Icon(Icons.map)),
                  ],
                  selected: <ViewState>{viewState},
                  onSelectionChanged: (Set<ViewState> selection) =>
                      setState(() {
                    viewState = selection.first;
                  }),
                ),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ActionChip(
                  label: Text('Filters'),
                  onPressed: () {
                    displayFilters(context);
                  },
                  avatar: Icon(Icons.filter_alt),
                ),
                SizedBox(
                  width: 10,
                ),
                ActionChip(
                  label: Text('Radius'),
                  onPressed: () async {
                    var chosenRadius = await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (builder) =>
                                RadiusSelectorWidget(pos!, radius)));

                    setState(() {
                      radius = chosenRadius.elementAt(0);
                      pos = createSimplePosition(chosenRadius.elementAt(1));
                      activities = [];
                      loadIds();
                    });
                  },
                  avatar: Icon(Icons.sort),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: filterChips),
            (_loading || pos == null)
                ? Center(child: CircularProgressIndicator())
                : (viewState == ViewState.map)
                    ? MapSearch(
                        pos: pos!,
                        activities: display_activities,
                        radius: radius)
                    : Expanded(
                        child: RefreshIndicator(
                          onRefresh: () {
                            setState(() {
                              activities = [];
                              loadIds();
                            });
                            return Future.value(true);
                          },
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: display_activities.length,
                            itemBuilder: (context, index) {
                              return ActivityCardWidget(
                                  activityData: display_activities[index],
                                  pos: pos);
                            },
                          ),
                        ),
                      ),
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
