import 'package:flutter/material.dart';

class SpecialtyModel {
  final String id;
  final String name;
  final String description;
  final int doctorCount;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final List<String> commonSymptoms;

  const SpecialtyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.doctorCount,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    this.commonSymptoms = const [],
  });
}
