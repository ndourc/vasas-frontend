import 'package:flutter/material.dart';

class Event {
  final String title;
  final DateTime date;
  final TimeOfDay time;
  final String description;
  final String venue;

  Event({
    required this.title,
    required this.date,
    required this.time,
    required this.description,
    required this.venue,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'description': description,
      'venue': venue,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      date: DateTime.parse(json['date']),
      time: TimeOfDay(
        hour: int.parse(json['time'].split(":")[0]),
        minute: int.parse(json['time'].split(":")[1]),
      ),
      description: json['description'],
      venue: json['venue'],
    );
  }
}
