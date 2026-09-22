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

  static Color _parseColor(String? hexString, Color fallback) {
    if (hexString == null || hexString.isEmpty) return fallback;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  static IconData _parseIcon(String? iconName) {
    switch (iconName) {
      case 'face_retouching_natural_rounded':
        return Icons.face_retouching_natural_rounded;
      case 'child_care_rounded':
        return Icons.child_care_rounded;
      case 'pregnant_woman_rounded':
        return Icons.pregnant_woman_rounded;
      case 'favorite_rounded':
        return Icons.favorite_rounded;
      case 'psychology_rounded':
        return Icons.psychology_rounded;
      case 'healing_rounded':
        return Icons.healing_rounded;
      case 'visibility_rounded':
        return Icons.visibility_rounded;
      case 'medical_services_rounded':
      default:
        return Icons.medical_services_rounded;
    }
  }

  factory SpecialtyModel.fromJson(Map<String, dynamic> json) {
    return SpecialtyModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      doctorCount: (json['doctorCount'] as num?)?.toInt() ?? 0,
      icon: _parseIcon(json['icon']?.toString()),
      iconColor: _parseColor(json['iconColorHex']?.toString(), const Color(0xFF1A56DB)),
      bgColor: _parseColor(json['bgColorHex']?.toString(), const Color(0xFFEBF5FF)),
      commonSymptoms: json['commonSymptoms'] != null
          ? List<String>.from(json['commonSymptoms'])
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'doctorCount': doctorCount,
      'commonSymptoms': commonSymptoms,
    };
  }
}

