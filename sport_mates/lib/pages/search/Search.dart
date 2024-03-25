import 'package:flutter/widgets.dart';
import 'package:sport_mates/config/auth_provider.dart';
import 'package:sport_mates/pages/feedback/history.dart';
import 'package:sport_mates/pages/general_purpuse/activity_card.dart';
import 'package:sport_mates/pages/search/choose_position.dart';
import 'package:sport_mates/pages/search/filter_chips.dart';
import 'package:sport_mates/pages/search/filter_data.dart';
import 'package:sport_mates/pages/search/filter_dialog.dart';
import 'package:sport_mates/pages/search/map_search.dart';
import 'package:sport_mates/pages/upcoming_activity/upcoming_activity.dart';
import 'package:sport_mates/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sport_mates/data/activity.dart';
import 'package:sport_mates/data/feedback.dart';
import 'package:sport_mates/config/config.dart';
import 'package:sport_mates/pages/new_activity/new_activity.dart';
import 'package:sport_mates/pages/settings/settings.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  bool _loading = true;

  Position? pos;
  double radius = 5000;
  List<Activity> activities = [];
  List<Activity> displayActivities = [];
  String token = '';
  List<FeedbackActivity> feedback = [];

  late TabController _tabController;

  FilterData filterData = FilterData.init();

  void displayFilters(BuildContext context) async {
    var data = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogFilter(filterData: filterData);
      },
    );
    filterState(data);
  }

  void filterState(FilterData data) {
    setState(() {
      filterData = data;
      displayActivities = filter(filterData, activities);
    });
  }

  Future<List<FeedbackActivity>> loadFeedback() async {
    final req = await http.get(Uri.https(Config().host, '/feedback'),
        headers: {'Authorization': 'Bearer ${token}'});
    if (req.statusCode != 200) {
      throw Exception('Failed to load feedback');
    }
    final feedback =
        json.decode(req.body).map((e) => FeedbackActivity.fromJson(e));
    return feedback.toList().cast<FeedbackActivity>();
  }

  Future<void> load() async {
    setState(() {
      this.activities = [];
      displayActivities = [];
      _loading = true;
      this.feedback = [];
    });
    try {
      var ids = await loadIds();
      var feedback = await loadFeedback();
      var activities = await loadAllActivitys(ids.cast<int>());
      var displayActivitis = filter(filterData, activities);
      setState(() {
        this.activities = activities;
        this.feedback = feedback;
        this.displayActivities = displayActivitis;
        _loading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> choosePositionRadius() async {
    var chosenRadius = await Navigator.of(context).push(MaterialPageRoute(
        builder: (builder) => RadiusSelectorWidget(pos!, radius)));

    radius = chosenRadius.elementAt(0);
    pos = createSimplePosition(chosenRadius.elementAt(1));

    filterState(filterData);
  }

  Future<List<int>> loadIds() async {
    final req = await http.get(Uri.https(Config().host, '/activities/search'));
    if (req.statusCode != 200) {
      throw Exception('Failed to load ids');
    }
    return json.decode(req.body).cast<int>();
  }

  Future<List<Activity>> loadAllActivitys(List<int> ids) async {
    var futures = ids.map((e) async {
      var value = await http.get(Uri.https(Config().host, '/activities/$e'));
      if (value.statusCode == 200) {
        return (Activity.fromJson(json.decode(value.body)));
      }
    }).toList();
    var result = await Future.wait(futures);
    return result.cast<Activity>();
  }

  List<Activity> filter(FilterData newFilterData, List<Activity> activities) {
    return displayActivities = activities.where((element) {
      if (element.numberOfPeople - element.participants.length <= 0) {
        return false;
      }
      if (filterData.price) {
        if (element.attributes.price > filterData.maxPrice) {
          return false;
        }
      }
      if (isInRatio(element.position,
          PositionActivity(long: pos!.longitude, lat: pos!.latitude), radius)) {
        return false;
      }
      if (filterData.selectedSport != Config().nullSport) {
        if (element.attributes.sport != filterData.selectedSport) {
          return false;
        }
      }
      if (DateTime.now().isAfter(element.time)) {
        return false;
      }
      if (filterData.startDate != null &&
          filterData.startDate!.isAfter(element.time)) {
        return false;
      }
      if (filterData.endDate != null &&
          filterData.endDate!.isBefore(element.time)) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> start() async {
    pos = await determinePosition();
    load();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    start();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var temp = Provider.of<AuthProvider>(context);
    final user = temp.getUsername!;
    token = temp.token!;

    var upcoming = upcomingFilter(user, activities, pos);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SearchAnchor(suggestionsBuilder: (context, controller) {
                return [
                  ListTile(
                      title: Text('Set Position and Radius'),
                      leading: Icon(Icons.location_on),
                      onTap: choosePositionRadius),
                  ListTile(
                    title: Text('Set Filters'),
                    leading: Icon(Icons.tune),
                    onTap: () => displayFilters(context),
                  ),
                  Divider(),
                ];
              }, builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  padding: const MaterialStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16.0)),
                  onTap: () {
                    controller.openView();
                  },
                  onChanged: (_) {
                    controller.openView();
                  },
                  leading: const Icon(Icons.search),
                  trailing: <Widget>[
                    Tooltip(
                        message: 'Set Filters',
                        child: Badge(
                          isLabelVisible: filterData.hasFilter(),
                          child: IconButton(
                            onPressed: () => displayFilters(context),
                            icon: const Icon(Icons.tune),
                          ),
                        )),
                    Tooltip(
                      message: 'Set Position and Radius',
                      child: IconButton(
                        onPressed: choosePositionRadius,
                        icon: const Icon(Icons.location_on),
                      ),
                    )
                  ],
                );
              }),
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    icon: Icon(Icons.list),
                  ),
                  Tab(
                    icon: Icon(Icons.map),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(controller: _tabController, children: [
                  (_loading || pos == null)
                      ? Center(child: CircularProgressIndicator())
                      : Expanded(
                          child: RefreshIndicator(
                            onRefresh: () {
                              return load();
                            },
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: displayActivities.length,
                              itemBuilder: (context, index) {
                                return ActivityCardWidget(
                                    onReturn: () {
                                      load();
                                    },
                                    activityData: displayActivities[index],
                                    pos: pos);
                              },
                            ),
                          ),
                        ),
                  (_loading || pos == null)
                      ? Center(child: CircularProgressIndicator())
                      : MapSearch(
                          pos: pos!,
                          activities: displayActivities,
                          radius: radius),
                ]),
              ),
            ],
          ),
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
                  onPressed: (_loading)
                      ? null
                      : () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (builder) => UpcoingActivity(
                                  activities: upcoming, pos: pos!)));
                          load();
                        },
                ),
              ),
              IconButton(
                icon: Icon(Icons.history),
                onPressed: (_loading)
                    ? null
                    : () {
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
        onPressed: () async {
          var created = Navigator.of(context).push(
              MaterialPageRoute(builder: (builder) => CreateActivityWidget()));

          if (created != null && created is bool && created == true) {
            load();
          }
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }
}
