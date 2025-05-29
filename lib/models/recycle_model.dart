import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class LoggedRecycleActivity {
  final String id;
  final String location;
  final String? description; 
  final XFile? mediaFile; 
  final DateTime timestamp;
  final IconData icon; 
  LoggedRecycleActivity({
    required this.id,
    required this.location,
    this.description,
    this.mediaFile,
    required this.timestamp,
    this.icon = Icons.recycling, 
  });
}

class RecyclingTip {
  final String title;
  final String description;
  final IconData icon;

  RecyclingTip({
    required this.title,
    required this.description,
    required this.icon,
  });
}