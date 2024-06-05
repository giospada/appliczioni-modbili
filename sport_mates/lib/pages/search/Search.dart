import 'package:latlong2/latlong.dart';
import 'package:sport_mates/config/auth_provider.dart';
import 'package:sport_mates/config/data_provider.dart';
import 'package:sport_mates/pages/feedback/history.dart';
import 'package:sport_mates/pages/general_purpuse/activity_card.dart';
import 'package:sport_mates/pages/search/choose_position.dart';
import 'package:sport_mates/pages/search/filter_data.dart';
import 'package:sport_mates/pages/search/filter_dialog.dart';
import 'package:sport_mates/pages/search/map_search.dart';
import 'package:sport_mates/pages/upcoming_activity/upcoming_activity.dart';
import 'package:sport_mates/utils.dart';
import 'package:flutter/material.dart';
import 'package:sport_mates/data/activity.dart';
import 'package:sport_mates/pages/new_activity/new_activity.dart';
import 'package:sport_mates/pages/settings/settings.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String? token;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      token = authProvider.token;
      if (token != null) {
        Provider.of<DataProvider>(context, listen: false).load(token!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(builder: (context, dataProvider, child) {
      return _SearchPage(
          key: UniqueKey(), data: dataProvider.toApplicationData());
    });
  }
}

class _SearchPage extends StatefulWidget {
  final ApplicationData data;

  _SearchPage({super.key, required this.data});

  @override
  State<_SearchPage> createState() => _SearchPageStateFilter(data);
}

class _SearchPageStateFilter extends State<_SearchPage>
    with TickerProviderStateMixin {
  LatLng? pos;
  double radius = 5000;
  List<Activity> displayActivities = [];
  String token = '';

  late TabController _tabController;
  FilterData filterData = FilterData.init();
  ApplicationData activityData;

  _SearchPageStateFilter(this.activityData);

  Future<void> displayFilters() async {
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
      displayActivities = filter(filterData, activityData.activities);
    });
  }

  Future<void> choosePositionRadius() async {
    List<Activity> activities =
        filter(FilterData.init(), activityData.activities);

    var chosenRadius = await Navigator.of(context).push(MaterialPageRoute(
        builder: (builder) => RadiusSelectorWidget(pos!, radius, activities)));

    radius = chosenRadius.elementAt(0);
    pos = chosenRadius.elementAt(1);
    if (pos != null) {
      Provider.of<DataProvider>(context, listen: false).lastPos = pos!;
    }
    filterState(filterData);
  }

  List<Activity> filter(FilterData newFilterData, List<Activity> activities) {
    return activities.where((element) {
      return newFilterData.isValidActivity(element, pos, radius);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    pos = activityData.lastPos;
    displayActivities = filter(filterData, activityData.activities);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.getUsername!;
    token = authProvider.token!;
    var upcoming = upcomingFilter(user, activityData.activities, pos);

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
                            title: const Text('Imposta posizione e raggio'),
                            leading: const Icon(Icons.location_on),
                            onTap: (activityData.loading)
                                ? null
                                : choosePositionRadius),
                        ListTile(
                          title: const Text('Imposta i filtri'),
                          leading: const Icon(Icons.tune),
                          onTap: (activityData.loading)
                              ? null
                              : () async {
                                  await displayFilters();
                                  controller.closeView(controller.text ?? "");
                                },
                        ),
                        const Divider(),
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
                      message: 'Imposta i filtri',
                      child: Badge(
                        isLabelVisible: filterData.hasFilter(),
                        child: IconButton(
                          onPressed: (activityData.loading)
                              ? null
                              : () => displayFilters(),
                          icon: const Icon(Icons.tune),
                        ),
                      )),
                  Tooltip(
                    message: 'Imposta la posizione e raggio',
                    child: IconButton(
                      onPressed:
                          (activityData.loading) ? null : choosePositionRadius,
                      icon: const Icon(Icons.location_on),
                    ),
                  )
                ],
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.list),
                  ),
                  Tab(
                    icon: Icon(Icons.map),
                  ),
                ],
              ),
              if (activityData.loading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          if (activityData.isConnected)
                            Text(
                                'ultimo aggiornamento ${activityData.lastUpdate}')
                          else if (activityData.isConnected)
                            Text(
                                'Non connesso, ultimo aggiornamento ${activityData.lastUpdate}'),
                        ],
                      ),
                      const Divider(),
                    ],
                  ),
                ),
              Expanded(
                child: TabBarView(controller: _tabController, children: [
                  (activityData.loading || pos == null)
                      ? const Center(child: CircularProgressIndicator())
                      : (displayActivities.isEmpty)
                          ? const Center(
                              child: Text(
                              'Nessuna attività trovata, prova a cambiare i filtri o la posizione',
                            ))
                          : RefreshIndicator(
                              onRefresh: () async {
                                Provider.of<DataProvider>(context,
                                        listen: false)
                                    .load(token);
                              },
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: displayActivities.length,
                                itemBuilder: (context, index) {
                                  return ActivityCardWidget(
                                      activityData: displayActivities[index],
                                      pos: pos!);
                                },
                              ),
                            ),
                  (activityData.loading || pos == null)
                      ? const Center(child: CircularProgressIndicator())
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
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (builder) => SettingsPage()));
                },
              ),
              Badge(
                isLabelVisible: upcoming.isNotEmpty,
                child: IconButton(
                  icon: const Icon(Icons.upcoming),
                  onPressed: (activityData.loading)
                      ? null
                      : () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (builder) => UpcoingActivity(
                                  activities: upcomingFilter(
                                      user, activityData.activities, pos),
                                  pos: pos!)));
                        },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: (activityData.loading)
                    ? null
                    : () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (builder) => const FeedbackPage()));
                      },
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var activity = await Navigator.of(context).push(MaterialPageRoute(
              builder: (builder) => CreateActivityWidget())) as Activity?;
          if (activity != null && context.mounted) {
            Provider.of<DataProvider>(context, listen: false)
                .addActivity(activity);
            filterState(filterData);
          }
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }
}
