import 'package:flutter/material.dart';

class Subject {
  final String id;
  final String name;
  final Color color;
  final IconData icon;

  Subject({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  // Convert Subject to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'icon': icon.codePoint,
    };
  }

  // Create Subject from JSON
  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      color: Color(json['color']),
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
    );
  }

  // Create a copy of the subject with some changes
  Subject copyWith({
    String? id,
    String? name,
    Color? color,
    IconData? icon,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }
}
