import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_mates/config/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:sport_mates/data/activity.dart';
import 'package:sport_mates/data/feedback.dart';
import 'package:http/http.dart' as http;

class DataProvider with ChangeNotifier {
  final storage = const FlutterSecureStorage();
  bool loading = false;
  bool isConnected = false;
  List<Activity> activities = [];
  List<FeedbackActivity> feedbacks = [];
  DateTime? lastUpdate = null;
  LatLng lastPos = LatLng(44.498955, 11.327591);
  bool loadingPos = false;

  void addActivity(Activity activity) {
    activities.add(activity);
    notifyListeners();
  }

  Future<void> deleteAllStoredData() async {
    await storage.deleteAll();
    loading = false;
    isConnected = false;
    activities = [];
    feedbacks = [];
    lastUpdate = null;
  }

  Future<void> loadFromStorage() async {
    final String? activitiesString = await storage.read(key: 'activities');
    final String? feedbacksString = await storage.read(key: 'feedbacks');
    final String? lastUpdateString = await storage.read(key: 'lastUpdate');
    final String? lastPosString = await storage.read(key: 'lastPos');
    if (activitiesString != null) {
      activities = (json.decode(activitiesString) as List)
          .map((e) => Activity.fromJson(e))
          .toList();
    }
    if (feedbacksString != null) {
      feedbacks = (json.decode(feedbacksString) as List)
          .map((e) => FeedbackActivity.fromJson(e))
          .toList();
    }
    if (lastUpdateString != null) {
      lastUpdate = DateTime.parse(lastUpdateString);
    }
    if (lastPosString != null) {
      lastPos = LatLng.fromJson(json.decode(lastPosString));
    }
  }

  Future<void> saveToStorage(DateTime lastUpdate) async {
    await storage.write(key: 'activities', value: json.encode(activities));
    await storage.write(key: 'feedbacks', value: json.encode(feedbacks));
    await storage.write(key: 'lastUpdate', value: lastUpdate.toIso8601String());
    await storage.write(key: 'lastPos', value: json.encode(lastPos));
  }

  Future<List<FeedbackActivity>> loadFeedback(token) async {
    final req = await http.get(Uri.https(Config().host, '/feedback'),
        headers: {'Authorization': 'Bearer ${token}'});
    if (req.statusCode != 200) {
      throw Exception('Impossibile caricare i feedback');
    }
    final feedback =
        json.decode(req.body).map((e) => FeedbackActivity.fromJson(e));
    return feedback.toList().cast<FeedbackActivity>();
  }

  int _findActivityIndex(int id) {
    return activities.indexWhere((element) => element.id == id);
  }

  void update_activity(
      List<Activity> updatedActivities, List<int> deletedActivities) {
    for (var i = 0; i < updatedActivities.length; i++) {
      var index = _findActivityIndex(updatedActivities[i].id);
      if (index != -1) {
        activities[index] = updatedActivities[i];
      } else {
        activities.add(updatedActivities[i]);
      }
    }
    for (var i = 0; i < deletedActivities.length; i++) {
      var index = _findActivityIndex(deletedActivities[i]);
      if (index != -1) {
        activities.removeAt(index);
        feedbacks.removeWhere(
            (element) => element.activityId == deletedActivities[i]);
      }
    }
  }

  Future<void> load(token) async {
    loading = true;
    notifyListeners();
    await loadFromStorage();
    try {
      var lastUpdate = DateTime.now();
      lastUpdate = lastUpdate.subtract(lastUpdate.timeZoneOffset);
      var ids = await _loadIds();
      var feedback = await loadFeedback(token);
      var updated_activities = await _loadAllActivitys(ids.cast<int>());
      var deleted_activities = await _deletedActivities(token);
      update_activity(updated_activities, deleted_activities);
      this.feedbacks = feedback;
      this.lastUpdate = DateTime.now();
      await saveToStorage(lastUpdate);
      loading = false;
      isConnected = true;
      notifyListeners();
    } catch (e) {
      loading = false;
      isConnected = false;
      notifyListeners();
    }
  }

  Future<List<int>> _loadIds() async {
    Map<String, dynamic> params = {};
    if (lastUpdate != null) {
      params['last_update'] = lastUpdate!.toIso8601String();
    }
    final req =
        await http.get(Uri.https(Config().host, '/activities/search', params));
    if (req.statusCode != 200) {
      throw Exception('Impossible caricare gli id attività');
    }
    return json.decode(req.body).cast<int>();
  }

  Future<List<Activity>> _loadAllActivitys(List<int> ids) async {
    var futures = ids.map((e) async {
      var value = await http.get(Uri.https(Config().host, '/activities/$e'));
      if (value.statusCode == 200) {
        return (Activity.fromJson(json.decode(value.body)));
      }
    }).toList();
    var result = await Future.wait(futures);
    return result.cast<Activity>();
  }

  Future<List<int>> _deletedActivities(token) async {
    final req = await http.get(Uri.https(Config().host, '/activities_delete'));
    if (req.statusCode != 200) {
      throw Exception('Impossibile caricare le attività cancellate');
    }
    return json.decode(req.body).cast<int>();
  }

  ApplicationData toApplicationData() {
    return ApplicationData(
        loading, isConnected, activities, feedbacks, lastUpdate, lastPos);
  }

  void joinActivity(int id, String user) {
    var index = _findActivityIndex(id);
    if (index != -1) {
      activities[index].participants.add(user);
      notifyListeners();
    }
  }

  void addFeedback(FeedbackActivity feedback) {
    feedbacks.add(feedback);
    notifyListeners();
  }

  void leaveActivity(int id, String user) {
    var index = _findActivityIndex(id);
    if (index != -1) {
      activities[index].participants.remove(user);
      notifyListeners();
    }
  }

  void deleteActivity(int id) {
    var index = _findActivityIndex(id);
    if (index != -1) {
      activities.removeAt(index);
      notifyListeners();
    }
  }
}

class ApplicationData {
  bool loading = false;
  bool isConnected = false;
  List<Activity> activities = [];
  List<FeedbackActivity> feedbacks = [];
  DateTime? lastUpdate = null;
  LatLng lastPos;

  ApplicationData(this.loading, this.isConnected, this.activities,
      this.feedbacks, this.lastUpdate, this.lastPos);
}
