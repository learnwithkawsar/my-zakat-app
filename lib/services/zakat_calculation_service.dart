import '../models/zakat_record_model.dart';
import '../models/settings_model.dart';
import 'database_service.dart';

class ZakatCalculationService {
  /// Get zakat year start and end dates for a given year
  static DateTime getZakatYearStart(int year) {
    return DateTime(year, 1, 1);
  }

  static DateTime getZakatYearEnd(int year) {
    return DateTime(year, 12, 31, 23, 59, 59);
  }

  /// Get current zakat year
  static int getCurrentZakatYear() {
    return DateTime.now().year;
  }

  /// Calculate zakat for a specific date range
  /// This calculates based on current assets, receivables, and liabilities
  static Future<ZakatRecordModel> calculateZakatForDateRange({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    String? notes,
  }) async {
    final settings = DatabaseService.getSettings();
    final zakatYearStart = startDate;
    final zakatYearEnd = endDate;

    // Calculate totals
    final assetsTotal = DatabaseService.calculateTotalAssets();
    final receivablesTotal = DatabaseService.calculateTotalReceivables();
    final liabilitiesTotal = DatabaseService.calculateTotalLiabilities();

    // Net zakatable amount
    final netZakatableAmount = assetsTotal + receivablesTotal - liabilitiesTotal;

    // Calculate zakat due
    double zakatDue = 0.0;
    if (netZakatableAmount >= settings.nisab) {
      zakatDue = netZakatableAmount * (settings.zakatRate / 100);
    }

    // Check if record already exists for this date range
    final existingRecord = DatabaseService.getZakatRecordByDateRange(
      startDate: zakatYearStart,
      endDate: zakatYearEnd,
    );
    
    if (existingRecord != null) {
      // Update existing record (preserve amountPaid, isCurrent, and name)
      final updated = existingRecord.copyWith(
        calculationDate: DateTime.now(),
        assetsTotal: assetsTotal,
        receivablesTotal: receivablesTotal,
        liabilitiesTotal: liabilitiesTotal,
        netZakatableAmount: netZakatableAmount,
        zakatDue: zakatDue,
        notes: notes ?? existingRecord.notes,
        name: name, // Update name if provided
        // Preserve isCurrent flag
      );
      await DatabaseService.updateZakatRecord(updated);
      return updated;
    } else {
      // Create new record
      final record = ZakatRecordModel(
        id: DatabaseService.generateId(),
        calculationDate: DateTime.now(),
        zakatYearStart: zakatYearStart,
        zakatYearEnd: zakatYearEnd,
        assetsTotal: assetsTotal,
        receivablesTotal: receivablesTotal,
        liabilitiesTotal: liabilitiesTotal,
        netZakatableAmount: netZakatableAmount,
        zakatDue: zakatDue,
        amountPaid: 0.0,
        isCurrent: false, // Will be set by controller if needed
        notes: notes,
        name: name,
      );
      await DatabaseService.addZakatRecord(record);
      return record;
    }
  }

  /// Calculate zakat for a specific year (convenience method)
  static Future<ZakatRecordModel> calculateZakatForYear({
    required int year,
    String? notes,
  }) async {
    return await calculateZakatForDateRange(
      name: 'Zakat Year $year',
      startDate: getZakatYearStart(year),
      endDate: getZakatYearEnd(year),
      notes: notes,
    );
  }

  /// Calculate zakat for current year
  static Future<ZakatRecordModel> calculateCurrentYearZakat({String? notes}) async {
    final currentYear = getCurrentZakatYear();
    return await calculateZakatForYear(year: currentYear, notes: notes);
  }
}

