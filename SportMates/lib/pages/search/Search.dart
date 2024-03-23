import 'package:SportMates/config/auth_provider.dart';
import 'package:SportMates/pages/feedback/history.dart';
import 'package:SportMates/pages/search/choose_radius.dart';
import 'package:SportMates/pages/search/filter_dialog.dart';
import 'package:SportMates/pages/search/map_search.dart';
import 'package:SportMates/pages/upcoming_activity/upcoming_activity.dart';
import 'package:SportMates/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:SportMates/data/activity.dart';
import 'package:SportMates/data/feedback.dart';
import 'package:SportMates/pages/general_purpuse/activity_card.dart';
import 'package:SportMates/config/config.dart';
import 'package:SportMates/pages/new_activity/new_activity.dart';
import 'package:SportMates/pages/settings/settings.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

enum ViewState { map, list }

class _SearchPageState extends State<SearchPage> {
  bool _loading = true;

  Position? pos;
  List<Activity> activities = [];
  List<Activity> display_activities = [];
  String token = '';
  List<FeedbackActivity> feedback = [];

  double radius = 5000;
  double maxPrice = 0;
  bool price = false;
  String selectedSport = Config().nullSport;
  DateTime? startDate = null, endDate = null;

  ViewState viewState = ViewState.list;

  void displayFilters(BuildContext context) async {
    var data = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogFilter();
      },
    );
    price = data[0];
    selectedSport = data[1];
    maxPrice = data[2];
    startDate = data[3];
    endDate = data[4];
    filter();
  }

  Future<void> loadFeedback() async {
    final req = await http.get(Uri.http(Config().host, '/feedback'),
        headers: {'Authorization': 'Bearer ${token}'});
    if (req.statusCode != 200) {
      throw Exception('Failed to load feedback');
    }
    final feedback =
        json.decode(req.body).map((e) => FeedbackActivity.fromJson(e));
    setState(() {
      this.feedback = feedback.toList().cast<FeedbackActivity>();
    });
  }

  void loadIds() async {
    setState(() {
      _loading = true;
    });
    final req = await http.get(Uri.http(Config().host, '/activities/search'));
    if (req.statusCode != 200) {
      throw Exception('Failed to load ids');
    }
    final ids = json.decode(req.body);
    await loadFeedback();
    loadAllActivitys(ids.cast<int>());
  }

  void loadAllActivitys(List<int> ids) async {
    var futures = ids.map((e) async {
      var value = await http.get(Uri.http(Config().host, '/activities/$e'));
      if (value.statusCode == 200) {
        return (Activity.fromJson(json.decode(value.body)));
      }
    }).toList();
    var result = await Future.wait(futures);
    activities = result.cast<Activity>();
    filter();
  }

  void filter() {
    setState(() {
      display_activities = activities.where((element) {
        if (element.numberOfPeople - element.participants.length <= 0) {
          return false;
        }
        if (price) {
          if (element.attributes.price > maxPrice) {
            return false;
          }
        }
        if (isInRatio(
            element.position,
            PositionActivity(long: pos!.longitude, lat: pos!.latitude),
            radius)) {
          return false;
        }
        if (selectedSport != Config().nullSport) {
          if (element.attributes.sport != selectedSport) {
            return false;
          }
        }
        if (DateTime.now().isAfter(element.time)) {
          return false;
        }
        if (startDate != null && startDate!.isAfter(element.time)) {
          return false;
        }
        if (endDate != null && endDate!.isBefore(element.time)) {
          return false;
        }
        return true;
      }).toList();
      _loading = false;
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

  List<Widget> createFilterChips() {
    List<Widget> filterChips = [];
    if (price) {
      filterChips.add(Chip(
        label: Text('Prezzo Massimo $maxPrice €'),
        avatar: Icon(Icons.filter),
        onDeleted: () {
          price = false;
          maxPrice = 0;
          filter();
        },
      ));
    }
    if (selectedSport != Config().nullSport) {
      filterChips.add(Chip(
        label: Text('Sport: $selectedSport'),
        avatar: Icon(Icons.filter),
        onDeleted: () {
          selectedSport = Config().nullSport;
          filter();
        },
      ));
    }
    if (startDate != null) {
      filterChips.add(Chip(
        label: Text(
            'Data minima: ${startDate!.day}/${startDate!.month}/${startDate!.year}'),
        avatar: Icon(Icons.filter),
        onDeleted: () {
          startDate = null;
          filter();
        },
      ));
    }
    if (endDate != null) {
      filterChips.add(Chip(
        label: Text(
            'Data massima: ${endDate!.day}/${endDate!.month}/${endDate!.year}'),
        avatar: Icon(Icons.filter),
        onDeleted: () {
          endDate = null;
          filter();
        },
      ));
    }
    return filterChips;
  }

  @override
  Widget build(BuildContext context) {
    var temp = Provider.of<AuthProvider>(context);
    final user = temp.getUsername!;
    token = temp.token!;

    var upcoming = upcomingFilter(user, activities, pos);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
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
                  label: Text('Radius and Position'),
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
                SizedBox(
                  width: 10,
                ),
                ActionChip(
                  label: Text('Refresh'),
                  onPressed: () async {
                    setState(() {
                      activities = [];
                      loadIds();
                    });
                  },
                  avatar: Icon(Icons.refresh),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: createFilterChips()),
            ),
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
                                  onReturn: () {
                                    setState(() {
                                      activities = [];
                                      loadIds();
                                    });
                                  },
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
              Badge(
                isLabelVisible: upcoming.isNotEmpty,
                child: IconButton(
                  icon: Icon(Icons.upcoming),
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (builder) =>
                            UpcoingActivity(activities: upcoming, pos: pos!)));
                    setState(() {
                      activities = [];
                      loadIds();
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.history),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (builder) => FeedbackPage(
                          activities: activities
                              .where((element) =>
                                  element.participants.contains(user) &&
                                  element.time.isBefore(DateTime.now()))
                              .toList(),
                          feedback: feedback)));
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
