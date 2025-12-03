/// Utility functions for DateTime conversion and formatting
/// Handles conversion from UTC to IST (Indian Standard Time, UTC+5:30)

class DateTimeUtils {
  // IST offset from UTC: +5 hours 30 minutes
  static const Duration _istOffset = Duration(hours: 5, minutes: 30);

  /// Convert UTC DateTime to IST
  /// Returns the same DateTime with IST offset applied
  static DateTime convertUtcToIst(DateTime utcDateTime) {
    // Ensure the input is treated as UTC
    final utc = utcDateTime.toUtc();
    // Add IST offset
    return utc.add(_istOffset);
  }

  /// Format time in IST as HH:mm (24-hour format)
  /// Returns null if input is null
  static String? formatTimeIST(DateTime? utcDateTime) {
    if (utcDateTime == null) return null;
    
    final istTime = convertUtcToIst(utcDateTime);
    return '${istTime.hour.toString().padLeft(2, '0')}:${istTime.minute.toString().padLeft(2, '0')}';
  }

  /// Format date in IST as dd/MM/yyyy
  /// Returns empty string if input is null
  static String formatDateIST(DateTime? utcDateTime) {
    if (utcDateTime == null) return '';
    
    final istDate = convertUtcToIst(utcDateTime);
    return '${istDate.day}/${istDate.month}/${istDate.year}';
  }

  /// Format full datetime in IST as dd/MM/yyyy HH:mm
  /// Returns null if input is null
  static String? formatDateTimeIST(DateTime? utcDateTime) {
    if (utcDateTime == null) return null;
    
    final istDateTime = convertUtcToIst(utcDateTime);
    return '${istDateTime.day}/${istDateTime.month}/${istDateTime.year} ${istDateTime.hour.toString().padLeft(2, '0')}:${istDateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Get current time in IST
  static DateTime nowIST() {
    return convertUtcToIst(DateTime.now().toUtc());
  }
}
