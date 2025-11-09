import 'package:get/get.dart';
import 'package:collection/collection.dart';
import '../../../models/zakat_record_model.dart';
import '../../../services/database_service.dart';
import '../../../services/zakat_calculation_service.dart';
import '../../../common/utils/error_handler.dart';

class ZakatYearController extends GetxController {
  final zakatYears = <ZakatRecordModel>[].obs;
  final isLoading = false.obs;
  bool _isCurrent = false; // Track if new year should be current

  @override
  void onInit() {
    super.onInit();
    loadZakatYears();
  }

  /// Load all zakat years
  Future<void> loadZakatYears() async {
    isLoading.value = true;
    try {
      final records = DatabaseService.getAllZakatRecords();
      // Sort by year descending
      records.sort((a, b) => b.zakatYearStart.year.compareTo(a.zakatYearStart.year));
      zakatYears.value = records;
    } catch (e) {
      ErrorHandler.handleError(e, context: 'Failed to load zakat years');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get current zakat year
  ZakatRecordModel? getCurrentYear() {
    return zakatYears.firstWhereOrNull((year) => year.isCurrent);
  }

  /// Create a new zakat year
  Future<bool> createZakatYear({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    bool isCurrent = false,
    String? notes,
  }) async {
    _isCurrent = isCurrent;
    try {
      // Validate dates
      if (endDate.isBefore(startDate)) {
        ErrorHandler.showWarning('End date must be after start date');
        return false;
      }

      // Check if dates overlap with existing year
      final overlapping = zakatYears.firstWhereOrNull((y) {
        return (startDate.isAfter(y.zakatYearStart) &&
                startDate.isBefore(y.zakatYearEnd)) ||
            (endDate.isAfter(y.zakatYearStart) &&
                endDate.isBefore(y.zakatYearEnd)) ||
            (startDate.isBefore(y.zakatYearStart) &&
                endDate.isAfter(y.zakatYearEnd)) ||
            (startDate.isAtSameMomentAs(y.zakatYearStart)) ||
            (endDate.isAtSameMomentAs(y.zakatYearEnd));
      });

      if (overlapping != null) {
        ErrorHandler.showWarning(
          'Zakat year dates overlap with existing year (${overlapping.zakatYear})',
        );
        return false;
      }

      // Unmark current year if setting this as current
      if (_isCurrent) {
        await _unmarkCurrentYear();
      }

      // Create zakat year record WITHOUT calculating zakat
      // User must explicitly calculate zakat later
      final record = await ZakatCalculationService.createZakatYearWithoutCalculation(
        name: name,
        startDate: startDate,
        endDate: endDate,
        notes: notes,
      );

      // Mark as current if checkbox is checked
      if (_isCurrent) {
        final updated = record.copyWith(isCurrent: true);
        await DatabaseService.updateZakatRecord(updated);
      }

      await loadZakatYears();
      ErrorHandler.showSuccess(
        'Zakat year "$name" created successfully',
      );
      return true;
    } catch (e) {
      ErrorHandler.handleError(e, context: 'Failed to create zakat year');
      return false;
    }
  }

  /// Update zakat year
  Future<bool> updateZakatYear(ZakatRecordModel year) async {
    try {
      await DatabaseService.updateZakatRecord(year);
      await loadZakatYears();
      ErrorHandler.showSuccess('Zakat year updated successfully');
      return true;
    } catch (e) {
      ErrorHandler.handleError(e, context: 'Failed to update zakat year');
      return false;
    }
  }

  /// Set a year as current
  Future<bool> setAsCurrent(String zakatRecordId) async {
    try {
      // Unmark all current years
      await _unmarkCurrentYear();

      // Mark selected year as current
      final year = zakatYears.firstWhereOrNull((y) => y.id == zakatRecordId);
      if (year != null) {
        final updated = year.copyWith(isCurrent: true);
        await DatabaseService.updateZakatRecord(updated);
        await loadZakatYears();
        ErrorHandler.showSuccess('Zakat year set as current');
        return true;
      }
      return false;
    } catch (e) {
      ErrorHandler.handleError(e, context: 'Failed to set current year');
      return false;
    }
  }

  /// Unmark current year
  Future<void> _unmarkCurrentYear() async {
    final current = getCurrentYear();
    if (current != null) {
      final updated = current.copyWith(isCurrent: false);
      await DatabaseService.updateZakatRecord(updated);
    }
  }

  /// Delete zakat year
  Future<bool> deleteZakatYear(String zakatRecordId) async {
    try {
      final year = zakatYears.firstWhereOrNull((y) => y.id == zakatRecordId);
      if (year == null) return false;

      // Check if it's the current year
      if (year.isCurrent) {
        ErrorHandler.showWarning(
          'Cannot delete the current zakat year. Please set another year as current first.',
        );
        return false;
      }

      // Check if there are payments
      final payments = DatabaseService.getZakatPaymentsByRecord(zakatRecordId);
      if (payments.isNotEmpty) {
        ErrorHandler.showWarning(
          'Cannot delete zakat year with existing payments. Please delete payments first.',
        );
        return false;
      }

      await DatabaseService.deleteZakatRecord(zakatRecordId);
      await loadZakatYears();
      ErrorHandler.showSuccess('Zakat year deleted successfully');
      return true;
    } catch (e) {
      ErrorHandler.handleError(e, context: 'Failed to delete zakat year');
      return false;
    }
  }

  /// Recalculate zakat for a year
  Future<bool> recalculateZakatYear({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    String? notes,
  }) async {
    try {
      await ZakatCalculationService.calculateZakatForDateRange(
        name: name,
        startDate: startDate,
        endDate: endDate,
        notes: notes,
      );
      await loadZakatYears();
      ErrorHandler.showSuccess('Zakat recalculated successfully');
      return true;
    } catch (e) {
      ErrorHandler.handleError(e, context: 'Failed to recalculate zakat');
      return false;
    }
  }

  /// Get zakat year by ID
  ZakatRecordModel? getZakatYearById(String id) {
    return zakatYears.firstWhereOrNull((year) => year.id == id);
  }
}

