import 'package:flutter/material.dart';
import 'dart:math';

class Category {
  final String name;
  final int courses;
  final List<Color> gradientColors;
  final double width;
  final double height;
  final String illustrationAsset;

  Category({
    required this.name,
    required this.courses,
    required this.gradientColors,
    required this.width,
    required this.height,
    required this.illustrationAsset,
  });

  // Convert JSON response to a Category object
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
      courses: json.containsKey('courses') ? json['courses'] : 0, 
      gradientColors: _convertHexToGradient(json['gradient_colors']),
      width: 0.25, // Consistent width
      height: _randomHeight(), // Randomized height for variation
      illustrationAsset: json['image'],
    );
  }

  // Convert Hex colors from API to Flutter `Color`
  static List<Color> _convertHexToGradient(List<dynamic> hexColors) {
    return hexColors.map((hex) => Color(int.parse(hex.replaceFirst('#', '0xFF')))).toList();
  }

  // Random height variation
  static double _randomHeight() {
    final List<double> heightOptions = [1.8, 2.0, 2.2, 2.4, 2.6]; // Different heights
    return heightOptions[Random().nextInt(heightOptions.length)];
  }
}
