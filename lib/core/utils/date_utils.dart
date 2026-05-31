import 'package:intl/intl.dart';

/// Date and time formatting helpers used across the app.
///
/// Centralizing format logic here ensures consistency and makes it
/// easy to adjust formats without touching multiple widgets.
class AppDateUtils {
  AppDateUtils._();

  /// Full date: "Thursday, May 29"
  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, MMMM d').format(date);
  }

  /// Short date: "May 29"
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  /// Day of week only: "Thu"
  static String formatDayOfWeek(DateTime date) {
    return DateFormat('EEE').format(date);
  }

  /// Time in 12-hour format: "3 PM"
  static String formatHour(DateTime date) {
    return DateFormat('h a').format(date);
  }

  /// Time with minutes: "3:30 PM"
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  /// Checks if a date is today.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Returns "Today" if the date is today, otherwise the day of week.
  static String formatDayLabel(DateTime date) {
    if (isToday(date)) return 'Today';
    return formatDayOfWeek(date);
  }
}
