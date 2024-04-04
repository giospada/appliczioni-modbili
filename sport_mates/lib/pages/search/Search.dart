import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_mates/config/auth_provider.dart';
import 'package:sport_mates/config/data_provider.dart';
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

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dataprovider = Provider.of<DataProvider>(context);
    dataprovider.isFirstLoad = true;
    return Consumer<DataProvider>(builder: (context, dataProvider, child) {
      return _SearchPage(dataProvider);
    });
  }
}

class _SearchPage extends StatefulWidget {
  DataProvider dataProvider;

  _SearchPage(this.dataProvider);

  @override
  State<_SearchPage> createState() => _SearchPageState(dataProvider);
}

class _SearchPageState extends State<_SearchPage>
    with TickerProviderStateMixin {
  LatLng? pos;
  double radius = 5000;
  List<Activity> displayActivities = [];
  String token = '';

  late TabController _tabController;
  FilterData filterData = FilterData.init();
  DataProvider dataProvider;

  _SearchPageState(this.dataProvider);

  Future<void> displayFilters(BuildContext context) async {
    var data = await showModalBottomSheet(
      context: context,
      builder: (context) => DialogFilter(filterData: filterData),
      isScrollControlled:
          true, // To make the bottom sheet take full screen height if necessary
    );
    if (data == null) return;

    filterState(data);
  }

  void filterState(FilterData data) {
    setState(() {
      filterData = data;
      displayActivities = filter(filterData, dataProvider.activities);
    });
  }

  Future<void> choosePositionRadius() async {
    var chosenRadius = await Navigator.of(context).push(MaterialPageRoute(
        builder: (builder) =>
            RadiusSelectorWidget(pos!, radius, dataProvider.activities)));

    radius = chosenRadius.elementAt(0);
    pos = chosenRadius.elementAt(1);

    filterState(filterData);
  }

  List<Activity> filter(FilterData newFilterData, List<Activity> activities) {
    return displayActivities = activities.where((element) {
      return newFilterData.isValidActivity(element, pos, radius);
    }).toList();
  }

  Future<void> start() async {
    pos = await determinePosition();
    filterState(filterData);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    dataProvider.loading = true;
    start();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.getUsername!;
    token = authProvider.token!;

    if (dataProvider.isFirstLoad) {
      dataProvider.load(token);
    }

    var upcoming = upcomingFilter(user, dataProvider.activities, pos);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SearchAnchor.bar(
                isFullScreen: true,
                suggestionsBuilder: (context, controller) {
                  return [
                        ListTile(
                            title: Text('Set Position and Radius'),
                            leading: Icon(Icons.location_on),
                            onTap: choosePositionRadius),
                        ListTile(
                          title: Text('Set Filters'),
                          leading: Icon(Icons.tune),
                          onTap: () async {
                            await displayFilters(context);
                            controller.closeView(controller.text ?? "");
                          },
                        ),
                        Divider(),
                      ] +
                      displayActivities
                          .where((element) =>
                              element.description
                                  .toLowerCase()
                                  .contains(controller.text.toLowerCase()) ||
                              element.participants.any((element) => element
                                  .toLowerCase()
                                  .contains(controller.text.toLowerCase())))
                          .map((e) => ActivityCardWidget(
                              activityData: e,
                              pos: pos,
                              onReturn: () =>
                                  controller.closeView(controller.text ?? "")))
                          .toList();
                },
                barLeading: const Icon(Icons.search),
                barTrailing: <Widget>[
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
              ),
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
                  (dataProvider.loading || pos == null)
                      ? Center(child: CircularProgressIndicator())
                      : (displayActivities.length == 0)
                          ? Center(
                              child: Text(
                                  'No activities founds, try to change the filters or the position'))
                          : RefreshIndicator(
                              onRefresh: () async {
                                Provider.of<DataProvider>(context).load(token);
                              },
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: displayActivities.length,
                                itemBuilder: (context, index) {
                                  return ActivityCardWidget(
                                      onReturn: () {
                                        Provider.of<DataProvider>(context)
                                            .load(token);
                                      },
                                      activityData: displayActivities[index],
                                      pos: pos!);
                                },
                              ),
                            ),
                  (dataProvider.loading || pos == null)
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
                  onPressed: (dataProvider.loading)
                      ? null
                      : () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (builder) => UpcoingActivity(
                                  activities: upcoming, pos: pos!)));
                          await Provider.of<DataProvider>(context).load(token);
                        },
                ),
              ),
              IconButton(
                icon: Icon(Icons.history),
                onPressed: (dataProvider.loading)
                    ? null
                    : () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (builder) => FeedbackPage(
                                activities: dataProvider.activities
                                    .where((element) =>
                                        element.participants.contains(user) &&
                                        element.time.isBefore(DateTime.now()))
                                    .toList(),
                                feedback: dataProvider.feedbacks)));
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
            await Provider.of<DataProvider>(context).load(token);
          }
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }
}
