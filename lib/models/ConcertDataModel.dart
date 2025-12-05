import 'package:gigmap_mobile_flutter/models/PlatformDataModel.dart';
import 'package:gigmap_mobile_flutter/models/VenueDataModel.dart';

class ConcertDataModel {
  int? id;
  String name;
  String date;
  String status;
  String description;
  String image;
  String genre;
  int userId;

  PlatformDataModel platform;
  VenueDataModel venue;

  List<int> attendees;

  ConcertDataModel({
    this.id,
    required this.name,
    required this.date,
    required this.status,
    required this.description,
    required this.image,
    required this.genre,
    required this.platform,
    required this.venue,
    required this.attendees,
    required this.userId
  });

  static ConcertDataModel objJson(Map<String, dynamic> json) {
    return ConcertDataModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      date: json['date'] as String,
      status: json['status'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      genre: json['genre'] as String,
      userId: json["userId"] ?? 0,
      platform: PlatformDataModel.objJson(json['platform']),
      venue: VenueDataModel.objJson(json['venue']),

      attendees: (json['attendees'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
    );
  }
}