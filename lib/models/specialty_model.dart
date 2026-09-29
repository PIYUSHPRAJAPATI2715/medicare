import 'package:flutter/material.dart';

class SpecialtyModel {
  final String id;
  final String name;
  final String description;
  final int doctorCount;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String? imageUrl;
  final List<String> commonSymptoms;

  const SpecialtyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.doctorCount,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    this.imageUrl,
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
    final lower = iconName?.toLowerCase() ?? '';
    switch (lower) {
      case 'sparkles':
      case 'face_retouching_natural_rounded':
      case 'dermatology':
      case 'skin':
        return Icons.face_retouching_natural_rounded;
      case 'baby':
      case 'child_care_rounded':
      case 'pediatrician':
      case 'pediatrics':
        return Icons.child_care_rounded;
      case 'hearthandshake':
      case 'pregnant_woman_rounded':
      case 'gynecologist':
      case 'gynecology':
        return Icons.pregnant_woman_rounded;
      case 'favorite_rounded':
      case 'heart':
      case 'activity':
      case 'cardiologist':
      case 'cardiology':
        return Icons.favorite_rounded;
      case 'brain':
      case 'psychology_rounded':
      case 'psychiatrist':
      case 'neurology':
        return Icons.psychology_rounded;
      case 'shield':
      case 'healing_rounded':
      case 'wellness':
        return Icons.healing_rounded;
      case 'eye':
      case 'visibility_rounded':
      case 'ophthalmologist':
        return Icons.visibility_rounded;
      case 'stethoscope':
      case 'medical_services_rounded':
      case 'general physician':
      default:
        return Icons.medical_services_rounded;
    }
  }

  factory SpecialtyModel.fromJson(Map<String, dynamic> json) {
    return SpecialtyModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      doctorCount: int.tryParse(json['doctorCount']?.toString() ?? '') ?? 0,
      icon: _parseIcon(json['icon']?.toString()),
      iconColor: _parseColor(json['iconColorHex']?.toString(), const Color(0xFF1A56DB)),
      bgColor: _parseColor(json['bgColorHex']?.toString(), const Color(0xFFEBF5FF)),
      imageUrl: json['imageUrl']?.toString(),
      commonSymptoms: (json['commonSymptoms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'doctorCount': doctorCount,
      'imageUrl': imageUrl,
      'commonSymptoms': commonSymptoms,
    };
  }
}
