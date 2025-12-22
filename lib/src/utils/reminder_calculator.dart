import 'date_parser.dart';
import 'duration_parser.dart';

/// Exception thrown when reminder calculation fails due to invalid data
class ReminderCalculationException implements Exception {
  final String message;
  ReminderCalculationException(this.message);

  @override
  String toString() => 'ReminderCalculationException: $message';
}

/// Utility class for calculating reminder times from medicine instructions
class ReminderCalculator {
  // Time slot to hour mapping (24-hour format)
  static const Map<String, int> SLOT_TO_HOUR = {
    'morning': 8,  // 8:00 AM
    'noon': 13,    // 1:00 PM
    'night': 20,   // 8:00 PM
  };

  /// Calculate all reminder times for a medicine
  /// Returns null if calculation fails
  static List<DateTime>? calculateReminderTimes(
    Map<String, dynamic> medicine, {
    bool throwOnError = false,
  }) {
    try {
      // Validate instructions exist
      final instructions = medicine['instructions'];
      if (instructions == null) {
        throw ReminderCalculationException('No instructions found');
      }

      // Validate slotOfDay
      final slots = instructions['slotOfDay'] as List?;
      if (slots == null || slots.isEmpty) {
        throw ReminderCalculationException('No time slots specified');
      }

      // Convert to List<String> and validate all slots
      final slotList = slots.cast<String>();
      final invalidSlots = slotList.where((s) => !SLOT_TO_HOUR.containsKey(s)).toList();
      if (invalidSlots.isNotEmpty) {
        throw ReminderCalculationException('Invalid time slots: ${invalidSlots.join(', ')}');
      }

      // Parse prescribed date (default to today if null/invalid)
      DateTime startDate;
      final prescribedDateStr = instructions['prescribedDate'] as String?;
      if (prescribedDateStr == null || prescribedDateStr.isEmpty) {
        final now = DateTime.now();
        startDate = DateTime(now.year, now.month, now.day);
      } else {
        final parsed = DateParser.parseDate(prescribedDateStr);
        if (parsed == null) {
          throw ReminderCalculationException('Could not parse prescribed date: $prescribedDateStr');
        }
        startDate = DateTime(parsed.year, parsed.month, parsed.day);
      }

      // Parse duration (null means continuous/indefinite)
      final durationStr = instructions['duration'] as String?;
      final durationDays = parseDurationToDays(durationStr);

      // Calculate reminder times
      final reminders = <DateTime>[];
      final now = DateTime.now();

      // If duration is null, schedule for 30 days (iOS limit consideration)
      final scheduleDays = durationDays ?? 30;

      // Generate reminders for each day in the duration
      for (int day = 0; day < scheduleDays; day++) {
        final currentDate = startDate.add(Duration(days: day));

        // For each time slot on this day
        for (final slot in slotList) {
          final hour = SLOT_TO_HOUR[slot]!;
          final reminderTime = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            hour,
            0, // minutes
            0, // seconds
          );

          // Only include future reminders
          if (reminderTime.isAfter(now)) {
            reminders.add(reminderTime);
          }
        }
      }

      // Sort by time
      reminders.sort((a, b) => a.compareTo(b));

      return reminders.isEmpty ? null : reminders;
    } catch (e) {
      if (throwOnError) rethrow;
      print('Error calculating reminders: $e');
      return null;
    }
  }

  /// Convert duration string to number of days
  /// Returns null if duration is null or cannot be parsed
  static int? parseDurationToDays(String? duration) {
    if (duration == null || duration.isEmpty) {
      return null;
    }

    // Extract number and unit from duration string
    final match = RegExp(r'(\d+)\s*(day|days|week|weeks|month|months)', caseSensitive: false)
        .firstMatch(duration);

    if (match != null) {
      final number = int.tryParse(match.group(1)!);
      if (number == null) return null;

      final unit = match.group(2)!.toLowerCase();

      if (unit.startsWith('day')) {
        return number;
      } else if (unit.startsWith('week')) {
        return number * 7;
      } else if (unit.startsWith('month')) {
        return number * 30; // Approximate
      }
    }

    return null;
  }

  /// Check if reminders are still active (not past duration end date)
  static bool isReminderActive(Map<String, dynamic> medicine) {
    try {
      final instructions = medicine['instructions'];
      if (instructions == null) return false;

      // If no duration, reminders are active indefinitely
      final durationStr = instructions['duration'] as String?;
      if (durationStr == null || durationStr.isEmpty) {
        return true;
      }

      // Parse duration
      final durationDays = parseDurationToDays(durationStr);
      if (durationDays == null) return true; // If can't parse, assume active

      // Parse prescribed date
      final prescribedDateStr = instructions['prescribedDate'] as String?;
      DateTime startDate;
      if (prescribedDateStr == null || prescribedDateStr.isEmpty) {
        final now = DateTime.now();
        startDate = DateTime(now.year, now.month, now.day);
      } else {
        final parsed = DateParser.parseDate(prescribedDateStr);
        if (parsed == null) return true; // If can't parse, assume active
        startDate = DateTime(parsed.year, parsed.month, parsed.day);
      }

      // Calculate end date
      final endDate = startDate.add(Duration(days: durationDays));
      final now = DateTime.now();

      // Active if we haven't passed the end date
      return now.isBefore(endDate) || DateParser.isSameDay(now, endDate);
    } catch (e) {
      print('Error checking if reminder is active: $e');
      return false;
    }
  }

  /// Get the next upcoming reminder time for a medicine
  /// Returns null if no upcoming reminders
  static DateTime? getNextReminderTime(Map<String, dynamic> medicine) {
    try {
      final reminders = calculateReminderTimes(medicine);
      if (reminders == null || reminders.isEmpty) {
        return null;
      }

      // Reminders are already sorted and filtered to future times
      return reminders.first;
    } catch (e) {
      print('Error getting next reminder time: $e');
      return null;
    }
  }

  /// Helper method to get the slot name for a given time
  /// Used for determining which slot a reminder belongs to
  static String? getSlotForTime(DateTime time) {
    final hour = time.hour;

    for (final entry in SLOT_TO_HOUR.entries) {
      if (entry.value == hour) {
        return entry.key;
      }
    }

    return null;
  }

  /// Helper method to format a time until text
  /// Used for displaying "next dose in X hours" type messages
  static String formatTimeUntil(DateTime time) {
    final now = DateTime.now();
    final difference = time.difference(now);

    if (difference.inMinutes < 5 && difference.inMinutes > -5) {
      return 'now';
    } else if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return '$minutes minute${minutes == 1 ? '' : 's'}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hour${hours == 1 ? '' : 's'}';
    } else {
      final days = difference.inDays;
      return '$days day${days == 1 ? '' : 's'}';
    }
  }
}
