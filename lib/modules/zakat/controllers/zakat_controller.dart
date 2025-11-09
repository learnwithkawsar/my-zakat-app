import 'package:get/get.dart';
import 'package:collection/collection.dart';
import '../../../models/zakat_record_model.dart';
import '../../../models/zakat_payment_model.dart';
import '../../../models/beneficiary_model.dart';
import '../../../services/database_service.dart';
import '../../../services/zakat_calculation_service.dart';
import '../../../common/utils/error_handler.dart';

class ZakatController extends GetxController {
  final zakatRecords = <ZakatRecordModel>[].obs;
  final currentYearRecord = Rxn<ZakatRecordModel>();
  final selectedYearRecord = Rxn<ZakatRecordModel>(); // Selected year for viewing
  final isLoading = false.obs;
  final isCalculating = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadZakatRecords();
  }

  /// Load all zakat records
  Future<void> loadZakatRecords() async {
    isLoading.value = true;
    try {
      final records = DatabaseService.getAllZakatRecords();
      zakatRecords.value = records;
      
      // Update current year record
      final currentYear = ZakatCalculationService.getCurrentZakatYear();
      currentYearRecord.value = DatabaseService.getZakatRecordByYear(currentYear);
      
      // Also check for isCurrent flag
      if (currentYearRecord.value == null) {
        final currentRecord = DatabaseService.getAllZakatRecords()
            .firstWhereOrNull((r) => r.isCurrent);
        currentYearRecord.value = currentRecord;
      }
      
      // Set selected year to current year by default
      if (selectedYearRecord.value == null) {
        selectedYearRecord.value = currentYearRecord.value;
      }
    } catch (e) {
      ErrorHandler.handleError(e, context: 'Failed to load zakat records');
    } finally {
      isLoading.value = false;
    }
  }

  /// Calculate zakat for current year (only if selected year is current)
  Future<bool> calculateCurrentYearZakat({String? notes}) async {
    // Check if selected year is the current year
    if (selectedYearRecord.value == null || !selectedYearRecord.value!.isCurrent) {
      ErrorHandler.showWarning('You can only calculate zakat for the current year. Please select the current year first.');
      return false;
    }
    
    isCalculating.value = true;
    try {
      final record = await ZakatCalculationService.calculateCurrentYearZakat(notes: notes);
      currentYearRecord.value = record;
      selectedYearRecord.value = record; // Update selected year as well
      await loadZakatRecords(); // Reload to update list
      ErrorHandler.showSuccess('Zakat calculated successfully');
      return true;
    } catch (e) {
      ErrorHandler.handleError(e, context: 'Failed to calculate zakat');
      return false;
    } finally {
      isCalculating.value = false;
    }
  }
  
  /// Set selected year record
  void setSelectedYearRecord(ZakatRecordModel? record) {
    selectedYearRecord.value = record;
  }
  
  /// Get current year record (isCurrent = true)
  ZakatRecordModel? getCurrentYearRecord() {
    return zakatRecords.firstWhereOrNull((r) => r.isCurrent);
  }

  /// Calculate zakat for a specific year
  Future<bool> calculateZakatForYear(int year, {String? notes}) async {
    isCalculating.value = true;
    try {
      await ZakatCalculationService.calculateZakatForYear(year: year, notes: notes);
      await loadZakatRecords();
      ErrorHandler.showSuccess('Zakat calculated successfully for year $year');
      return true;
    } catch (e) {
      ErrorHandler.handleError(e, context: 'Failed to calculate zakat');
      return false;
    } finally {
      isCalculating.value = false;
    }
  }

  /// Get zakat record by year
  ZakatRecordModel? getZakatRecordByYear(int year) {
    return zakatRecords.firstWhereOrNull(
      (record) => record.zakatYearStart.year == year,
    );
  }

  /// Add zakat payment
  Future<bool> addZakatPayment({
    required String zakatRecordId,
    required String beneficiaryId,
    required double amount,
    required DateTime paymentDate,
    String? notes,
  }) async {
    try {
      final payment = ZakatPaymentModel(
        id: DatabaseService.generateId(),
        zakatRecordId: zakatRecordId,
        beneficiaryId: beneficiaryId,
        amount: amount,
        paymentDate: paymentDate,
        notes: notes,
      );

      await DatabaseService.addZakatPayment(payment);
      
      // Reload records to update amount paid
      await loadZakatRecords();
      
      ErrorHandler.showSuccess('Zakat payment recorded successfully');
      return true;
    } catch (e) {
      ErrorHandler.handleError(e, context: 'Failed to add zakat payment');
      return false;
    }
  }

  /// Get payments for a zakat record
  List<ZakatPaymentModel> getPaymentsForRecord(String zakatRecordId) {
    return DatabaseService.getZakatPaymentsByRecord(zakatRecordId);
  }

  /// Get all beneficiaries
  List<BeneficiaryModel> getAllBeneficiaries() {
    return DatabaseService.getAllBeneficiaries();
  }

  /// Get total paid for a zakat record
  double getTotalPaidForRecord(String zakatRecordId) {
    final payments = getPaymentsForRecord(zakatRecordId);
    return payments.fold<double>(0.0, (sum, payment) => sum + payment.amount);
  }
}

