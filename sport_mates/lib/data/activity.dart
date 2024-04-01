import 'package:latlong2/latlong.dart';

class Activity {
  final String description;
  final DateTime time;
  final LatLng position;
  final Attributes attributes;
  final int numberOfPeople;
  final int id;
  final List<String> participants;
  final String creator;

  Activity({
    required this.description,
    required this.time,
    required this.position,
    required this.attributes,
    required this.numberOfPeople,
    required this.id,
    required this.participants,
    required this.creator,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      description: json['description'],
      time: DateTime.parse(json['time']),
      position: LatLng(
        json['position']['lat'],
        json['position']['long'],
      ),
      attributes: Attributes(
        level: json['attributes']['level'],
        price: json['attributes']['price'],
        sport: json['attributes']['sport'],
      ),
      numberOfPeople: json['numberOfPeople'],
      id: json['id'],
      participants: List<String>.from(json['participants']),
      creator: json['creator'],
    );
  }
}

class Attributes {
  final String level;
  final int price;
  final String sport;

  Attributes({
    required this.level,
    required this.price,
    required this.sport,
  });
}
