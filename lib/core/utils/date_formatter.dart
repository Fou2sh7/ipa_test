import 'dart:ui';

import 'package:intl/intl.dart';

/// Helper class for formatting dates
class DateFormatter {
  /// Format date string to "27 Nov 2024" format
  /// Accepts various date formats and returns formatted string
  static String formatDate(String dateString) {
    try {
      // Try to parse the date string
      DateTime? date;
      
      // Try common date formats
      final formats = [
        'yyyy-MM-dd',           // 2024-11-27
        'dd/MM/yyyy',           // 27/11/2024
        'MM/dd/yyyy',           // 11/27/2024
        'dd-MM-yyyy',           // 27-11-2024
        'yyyy/MM/dd',           // 2024/11/27
        'dd MMM yyyy',          // 27 Nov 2024
        'MMM dd, yyyy',         // Nov 27, 2024
        'yyyy-MM-dd HH:mm:ss',  // 2024-11-27 10:30:00
      ];
      
      for (final format in formats) {
        try {
          date = DateFormat(format).parse(dateString);
          break;
        } catch (e) {
          continue;
        }
      }
      
      // If no format worked, return original string
      if (date == null) {
        return dateString;
      }
      
      // Format to "27 Nov 2024"
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      // If any error occurs, return original string
      return dateString;
    }
  }
  
  /// Format time string to "10:30 AM" format (always in English)
  static String formatTime(String timeString) {
    try {
      // Try to parse the time string
      DateTime? time;
      
      // Try common time formats (use English locale for parsing)
      final formats = [
        'HH:mm:ss',    // 14:30:00 (24-hour)
        'HH:mm',       // 14:30 (24-hour)
        'hh:mm a',     // 10:30 AM (12-hour)
        'hh:mm:ss a',  // 10:30:00 AM (12-hour)
      ];
      
      // Use English locale for parsing to ensure consistent behavior
      final englishLocale = const Locale('en', 'US');
      
      for (final format in formats) {
        try {
          time = DateFormat(format, 'en_US').parse(timeString);
          break;
        } catch (e) {
          continue;
        }
      }
      
      // If no format worked, try manual parsing for HH:mm format
      if (time == null) {
        // Try to parse as HH:mm or HH:mm:ss manually
        final parts = timeString.trim().split(':');
        if (parts.length >= 2) {
          try {
            final hour = int.parse(parts[0]);
            final minute = int.parse(parts[1].split(' ')[0]); // Handle seconds or AM/PM
            if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
              // Create a DateTime with today's date and the parsed time
              final now = DateTime.now();
              time = DateTime(now.year, now.month, now.day, hour, minute);
            }
          } catch (e) {
            // If parsing fails, return original string
            return timeString;
          }
        }
      }
      
      // If still no time, return original string
      if (time == null) {
        return timeString;
      }
      
      // Format to "10:30 AM" using English locale to ensure AM/PM in English
      return DateFormat('hh:mm a', 'en_US').format(time);
    } catch (e) {
      // If any error occurs, return original string
      return timeString;
    }
  }
  
  /// Format date and time together
  static String formatDateTime(String dateString, String timeString) {
    final formattedDate = formatDate(dateString);
    final formattedTime = formatTime(timeString);
    return '$formattedDate at $formattedTime';
  }
}
