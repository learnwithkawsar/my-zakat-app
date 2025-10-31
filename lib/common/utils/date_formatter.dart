import 'package:intl/intl.dart';

class DateFormatter {
  /// Format date to display format (e.g., "Jan 15, 2024")
  static String formatDisplay(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format date to short format (e.g., "01/15/2024")
  static String formatShort(DateTime date) {
    return DateFormat('MM/dd/yyyy').format(date);
  }

  /// Format date to long format (e.g., "January 15, 2024")
  static String formatLong(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  /// Format date with time (e.g., "Jan 15, 2024 10:30 AM")
  static String formatWithTime(DateTime date) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
  }

  /// Format date to ISO string
  static String formatISO(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format relative time (e.g., "2 days ago", "in 3 days")
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays == -1) {
      return 'Yesterday';
    } else if (difference.inDays > 0) {
      return 'In ${difference.inDays} days';
    } else {
      return '${-difference.inDays} days ago';
    }
  }

  /// Check if date is overdue
  static bool isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    return dueDate.isBefore(DateTime.now());
  }

  /// Get days until due date
  static int? daysUntilDue(DateTime? dueDate) {
    if (dueDate == null) return null;
    final difference = dueDate.difference(DateTime.now());
    return difference.inDays;
  }

  /// Format date range (e.g., "Jan 15 - Jan 20, 2024")
  static String formatRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${DateFormat('MMM dd').format(start)} - ${DateFormat('dd, yyyy').format(end)}';
    } else if (start.year == end.year) {
      return '${DateFormat('MMM dd').format(start)} - ${DateFormat('MMM dd, yyyy').format(end)}';
    } else {
      return '${formatDisplay(start)} - ${formatDisplay(end)}';
    }
  }
}

