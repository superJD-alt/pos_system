import 'package:pos_system/models/health_model.dart';
import 'package:flutter/material.dart';

class HealthDetails {
  final healthData = const [
    HealthModel(
      icon: "assets/icons/burn.png",
      value: "10,000",
      title: "Calories burned",
    ),
    HealthModel(icon: "assets/icons/steps.png", value: "72", title: "Steps"),
    HealthModel(
      icon: "assets/icons/distance.png",
      value: "30 min",
      title: "Distance",
    ),
    HealthModel(
      icon: "assets/icons/sleep.png",
      value: "80 bpm",
      title: "Sleep",
    ),
  ];
}
