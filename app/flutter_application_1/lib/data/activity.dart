class Activity {
  final String description;
  final DateTime time;
  final Position position;
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
      position: Position(
        long: json['position']['long'],
        lat: json['position']['lat'],
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

class Position {
  final double long;
  final double lat;

  Position({
    required this.long,
    required this.lat,
  });
}

class Attributes {
  final String level;
  final double price;
  final String sport;

  Attributes({
    required this.level,
    required this.price,
    required this.sport,
  });
}
