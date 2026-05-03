import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String color;   // hex string e.g. "#4CAF50"
  final String icon;    // emoji
  final bool   isCustom;

  const Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.isCustom = false,
  });

  factory Category.fromJson(Map<String, dynamic> j) => Category(
        id:       j['id'] as String,
        name:     j['name'] as String,
        color:    j['color'] as String,
        icon:     j['icon'] as String,
        isCustom: j['isCustom'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'name': name, 'color': color, 'icon': icon,
      };

  Color get flutterColor {
    final hex = color.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
