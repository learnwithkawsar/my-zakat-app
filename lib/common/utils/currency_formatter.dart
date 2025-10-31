import 'package:intl/intl.dart';

class CurrencyFormatter {
  /// Format currency amount with locale
  static String format({
    required double amount,
    required String currency,
    int decimalPlaces = 2,
  }) {
    final formatter = NumberFormat.currency(
      symbol: _getCurrencySymbol(currency),
      decimalDigits: decimalPlaces,
    );
    return formatter.format(amount);
  }

  /// Format currency without symbol (just number with formatting)
  static String formatNumber({
    required double amount,
    int decimalPlaces = 2,
  }) {
    final formatter = NumberFormat('#,##0.${'0' * decimalPlaces}');
    return formatter.format(amount);
  }

  /// Parse currency string to double
  static double? parse(String value, String currency) {
    try {
      // Remove currency symbol and spaces
      final cleaned = value
          .replaceAll(_getCurrencySymbol(currency), '')
          .replaceAll(',', '')
          .replaceAll(' ', '')
          .trim();
      return double.tryParse(cleaned);
    } catch (e) {
      return null;
    }
  }

  /// Get currency symbol
  static String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'BDT':
        return '৳';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'SAR':
        return 'ر.س';
      case 'AED':
        return 'د.إ';
      case 'PKR':
        return '₨';
      case 'INR':
        return '₹';
      default:
        return currency;
    }
  }

  /// Format compact currency (e.g., 1.5K, 2.3M)
  static String formatCompact({
    required double amount,
    required String currency,
  }) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ${_getCurrencySymbol(currency)}';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K ${_getCurrencySymbol(currency)}';
    }
    return format(amount: amount, currency: currency);
  }
}

