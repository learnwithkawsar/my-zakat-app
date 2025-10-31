class AppConstants {
  // App Info
  static const String appName = 'Zakat App';
  static const String appVersion = '1.0.0';

  // Default Values
  static const double defaultZakatRate = 2.5;
  static const String defaultCurrency = 'BDT';
  static const int defaultAutoLockMinutes = 5;
  static const int pinMinLength = 4;
  static const int pinMaxLength = 6;

  // Currency Codes
  static const List<String> supportedCurrencies = [
    'BDT',
    'USD',
    'EUR',
    'GBP',
    'SAR',
    'AED',
    'PKR',
    'INR',
  ];

  // Asset Types
  static const List<String> assetTypeNames = [
    'Cash',
    'Bank',
    'Gold',
    'Silver',
    'Investment',
    'Property',
    'Business',
    'Other',
  ];

  // Liability Types
  static const List<String> liabilityTypeNames = [
    'Short-term',
    'Long-term',
  ];

  // Loan Status
  static const List<String> loanStatusNames = [
    'Active',
    'Closed',
  ];

  // Zakat Calculation
  static const double goldNisabGrams = 87.48; // Standard gold nisab
  static const double silverNisabGrams = 612.36; // Standard silver nisab

  // Date Formats
  static const String dateFormatDisplay = 'MMM dd, yyyy';
  static const String dateFormatShort = 'MM/dd/yyyy';
  static const String dateFormatLong = 'MMMM dd, yyyy';
  static const String dateFormatISO = 'yyyy-MM-dd';

  // Validation
  static const int minAmountDecimalPlaces = 0;
  static const int maxAmountDecimalPlaces = 2;
  static const int maxNotesLength = 1000;
  static const int maxNameLength = 100;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Notification
  static const int zakatReminderDaysBefore = 7;
  static const int loanDueReminderDaysBefore = 3;
  static const int liabilityDueReminderDaysBefore = 3;

  // Backup
  static const String backupFileExtension = '.zakat_backup';
  static const String backupFileNamePrefix = 'zakat_backup_';

  // UI
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardElevation = 2.0;
}

