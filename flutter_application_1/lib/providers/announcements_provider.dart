import 'package:flutter/foundation.dart';
import '../services/announcements_service.dart';
import '../models/announcement_model.dart';

// Announcements provider/state management
class AnnouncementsProvider with ChangeNotifier {
  final AnnouncementsService _announcementsService = AnnouncementsService();

  List<AnnouncementModel> _announcements = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<AnnouncementModel> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch announcements for worker's sites
  Future<bool> fetchAnnouncements({required String token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _announcementsService.getMySitesAnnouncements(
        token: token,
      );

      if (result['success'] == true) {
        final data = result['data'];
        
        // Handle different response formats
        List<dynamic> announcementsList = [];
        if (data is List) {
          announcementsList = data;
        } else if (data is Map && data['announcements'] != null) {
          announcementsList = data['announcements'] as List<dynamic>;
        } else if (data is Map && data['data'] != null) {
          announcementsList = data['data'] as List<dynamic>;
        }

        _announcements = announcementsList
            .map((announcement) =>
                AnnouncementModel.fromJson(announcement as Map<String, dynamic>))
            .toList();

        // Sort by priority and date (high priority first, then by date descending)
        _announcements.sort((a, b) {
          final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
          final aPriority = priorityOrder[a.priority.toLowerCase()] ?? 3;
          final bPriority = priorityOrder[b.priority.toLowerCase()] ?? 3;
          
          if (aPriority != bPriority) {
            return aPriority.compareTo(bPriority);
          }
          
          return b.createdAt.compareTo(a.createdAt);
        });

        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = 'Failed to fetch announcements';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Mark announcement as read
  void markAsRead(String announcementId) {
    final index = _announcements.indexWhere((a) => a.id == announcementId);
    if (index != -1) {
      // Create a new instance with isRead = true
      final announcement = _announcements[index];
      _announcements[index] = AnnouncementModel(
        id: announcement.id,
        title: announcement.title,
        message: announcement.message,
        siteId: announcement.siteId,
        siteName: announcement.siteName,
        priority: announcement.priority,
        createdAt: announcement.createdAt,
        updatedAt: announcement.updatedAt,
        expiryDate: announcement.expiryDate,
        isRead: true,
        isActive: announcement.isActive,
      );
      notifyListeners();
    }
  }
}

