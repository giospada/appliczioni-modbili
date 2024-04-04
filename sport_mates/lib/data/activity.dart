import 'dart:convert';

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
      attributes: Attributes.fromJson(json['attributes']),
      numberOfPeople: json['numberOfPeople'],
      id: json['id'],
      participants: List<String>.from(json['participants']),
      creator: json['creator'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'time': time.toIso8601String(),
      'position': {
        'lat': position.latitude,
        'long': position.longitude,
      },
      'attributes': attributes.toJson(),
      'numberOfPeople': numberOfPeople,
      'id': id,
      'participants': participants,
      'creator': creator,
    };
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

  factory Attributes.fromJson(Map<String, dynamic> json) {
    return Attributes(
      level: json['level'],
      price: json['price'],
      sport: json['sport'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'price': price,
      'sport': sport,
    };
  }
}
