import 'package:flutter/material.dart';
import '../utils/date_time_utils.dart';

// Announcement model
class AnnouncementModel {
  final String id;
  final String title;
  final String message;
  final String? siteId;
  final String? siteName;
  final String priority; // 'high', 'medium', 'low'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? expiryDate;
  final bool isRead;
  final bool isActive;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    this.siteId,
    this.siteName,
    required this.priority,
    required this.createdAt,
    this.updatedAt,
    this.expiryDate,
    this.isRead = false,
    this.isActive = true,
  });

  // Create AnnouncementModel from JSON
  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      siteId: json['site_id'] as String?,
      siteName: json['site_name'] as String?,
      priority: json['priority'] as String? ?? 'medium',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      isRead: json['is_read'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  // Convert AnnouncementModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'site_id': siteId,
      'site_name': siteName,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'is_read': isRead,
      'is_active': isActive,
    };
  }

  // Get priority color
  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Get formatted date (in IST)
  String get formattedDate {
    return DateTimeUtils.formatDateIST(createdAt);
  }

  // Get formatted time (in IST)
  String get formattedTime {
    return DateTimeUtils.formatTimeIST(createdAt) ?? '--:--';
  }

  // Check if announcement is expired or deactivated
  bool get isExpired {
    // Treat deactivated announcements as expired
    if (!isActive) return true;
    // Check if past expiry date (compare in IST)
    if (expiryDate == null) return false;
    final nowIST = DateTimeUtils.nowIST();
    final expiryIST = DateTimeUtils.convertUtcToIst(expiryDate!);
    return nowIST.isAfter(expiryIST);
  }
}

