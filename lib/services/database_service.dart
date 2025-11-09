import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/borrower_model.dart';
import '../models/loan_model.dart';
import '../models/payment_model.dart';
import '../models/asset_model.dart';
import '../models/liability_model.dart';
import '../models/beneficiary_model.dart';
import '../models/zakat_record_model.dart';
import '../models/snapshot_model.dart';
import '../models/settings_model.dart';

class DatabaseService {
  static const String _borrowersBoxName = 'borrowers';
  static const String _loansBoxName = 'loans';
  static const String _paymentsBoxName = 'payments';
  static const String _assetsBoxName = 'assets';
  static const String _liabilitiesBoxName = 'liabilities';
  static const String _beneficiariesBoxName = 'beneficiaries';
  static const String _zakatRecordsBoxName = 'zakat_records';
  static const String _snapshotsBoxName = 'snapshots';
  static const String _settingsBoxName = 'settings';

  static final Uuid _uuid = const Uuid();

  // Box references
  static Box<BorrowerModel>? _borrowersBox;
  static Box<LoanModel>? _loansBox;
  static Box<PaymentModel>? _paymentsBox;
  static Box<AssetModel>? _assetsBox;
  static Box<LiabilityModel>? _liabilitiesBox;
  static Box<BeneficiaryModel>? _beneficiariesBox;
  static Box<ZakatRecordModel>? _zakatRecordsBox;
  static Box<SnapshotModel>? _snapshotsBox;
  static Box<SettingsModel>? _settingsBox;

  /// Initialize all Hive boxes
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(BorrowerModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(LoanModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(PaymentModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(AssetModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(LiabilityModelAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(BeneficiaryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(ZakatRecordModelAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(SnapshotModelAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(SettingsModelAdapter());
    }

    // Open boxes
    _borrowersBox = await Hive.openBox<BorrowerModel>(_borrowersBoxName);
    _loansBox = await Hive.openBox<LoanModel>(_loansBoxName);
    _paymentsBox = await Hive.openBox<PaymentModel>(_paymentsBoxName);
    _assetsBox = await Hive.openBox<AssetModel>(_assetsBoxName);
    _liabilitiesBox = await Hive.openBox<LiabilityModel>(_liabilitiesBoxName);
    _beneficiariesBox = await Hive.openBox<BeneficiaryModel>(_beneficiariesBoxName);
    _zakatRecordsBox = await Hive.openBox<ZakatRecordModel>(_zakatRecordsBoxName);
    _snapshotsBox = await Hive.openBox<SnapshotModel>(_snapshotsBoxName);
    _settingsBox = await Hive.openBox<SettingsModel>(_settingsBoxName);

    // Initialize default settings if not exists
    await _initializeDefaultSettings();
  }

  /// Initialize default settings
  static Future<void> _initializeDefaultSettings() async {
    if (_settingsBox!.isEmpty) {
      final defaultSettings = SettingsModel();
      await _settingsBox!.put('default', defaultSettings);
    }
  }

  /// Generate new UUID
  static String generateId() => _uuid.v4();

  // ==================== Borrowers ====================

  static Future<String> addBorrower(BorrowerModel borrower) async {
    await _borrowersBox!.put(borrower.id, borrower);
    return borrower.id;
  }

  static BorrowerModel? getBorrower(String id) {
    return _borrowersBox!.get(id);
  }

  static List<BorrowerModel> getAllBorrowers() {
    return _borrowersBox!.values.toList();
  }

  static Future<void> updateBorrower(BorrowerModel borrower) async {
    await _borrowersBox!.put(borrower.id, borrower);
  }

  static Future<void> deleteBorrower(String id) async {
    await _borrowersBox!.delete(id);
  }

  // ==================== Loans ====================

  static Future<String> addLoan(LoanModel loan) async {
    await _loansBox!.put(loan.id, loan);
    return loan.id;
  }

  static LoanModel? getLoan(String id) {
    return _loansBox!.get(id);
  }

  static List<LoanModel> getAllLoans() {
    return _loansBox!.values.toList();
  }

  static List<LoanModel> getLoansByBorrower(String borrowerId) {
    return _loansBox!.values
        .where((loan) => loan.borrowerId == borrowerId)
        .toList();
  }

  static List<LoanModel> getActiveLoans() {
    // All loans are considered active (no status field)
    return _loansBox!.values.toList();
  }

  static Future<void> updateLoan(LoanModel loan) async {
    await _loansBox!.put(loan.id, loan);
  }

  static Future<void> deleteLoan(String id) async {
    await _loansBox!.delete(id);
  }

  // ==================== Payments ====================

  static Future<String> addPayment(PaymentModel payment) async {
    await _paymentsBox!.put(payment.id, payment);
    return payment.id;
  }

  static PaymentModel? getPayment(String id) {
    return _paymentsBox!.get(id);
  }

  static List<PaymentModel> getAllPayments() {
    return _paymentsBox!.values.toList();
  }

  static List<PaymentModel> getPaymentsByLoan(String loanId) {
    return _paymentsBox!.values
        .where((payment) => payment.loanId == loanId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<void> updatePayment(PaymentModel payment) async {
    await _paymentsBox!.put(payment.id, payment);
  }

  static Future<void> deletePayment(String id) async {
    await _paymentsBox!.delete(id);
  }

  // ==================== Assets ====================

  static Future<String> addAsset(AssetModel asset) async {
    await _assetsBox!.put(asset.id, asset);
    return asset.id;
  }

  static AssetModel? getAsset(String id) {
    return _assetsBox!.get(id);
  }

  static List<AssetModel> getAllAssets() {
    return _assetsBox!.values.toList();
  }

  static List<AssetModel> getAssetsByType(AssetType type) {
    return _assetsBox!.values.where((asset) => asset.type == type).toList();
  }

  static Future<void> updateAsset(AssetModel asset) async {
    await _assetsBox!.put(asset.id, asset);
  }

  static Future<void> deleteAsset(String id) async {
    await _assetsBox!.delete(id);
  }

  // ==================== Liabilities ====================

  static Future<String> addLiability(LiabilityModel liability) async {
    await _liabilitiesBox!.put(liability.id, liability);
    return liability.id;
  }

  static LiabilityModel? getLiability(String id) {
    return _liabilitiesBox!.get(id);
  }

  static List<LiabilityModel> getAllLiabilities() {
    return _liabilitiesBox!.values.toList();
  }

  static List<LiabilityModel> getLiabilitiesByType(LiabilityType type) {
    return _liabilitiesBox!.values
        .where((liability) => liability.type == type)
        .toList();
  }

  static List<LiabilityModel> getIncludedLiabilities() {
    return _liabilitiesBox!.values
        .where((liability) => liability.includeInZakat)
        .toList();
  }

  static Future<void> updateLiability(LiabilityModel liability) async {
    await _liabilitiesBox!.put(liability.id, liability);
  }

  static Future<void> deleteLiability(String id) async {
    await _liabilitiesBox!.delete(id);
  }

  // ==================== Beneficiaries ====================

  static Future<String> addBeneficiary(BeneficiaryModel beneficiary) async {
    await _beneficiariesBox!.put(beneficiary.id, beneficiary);
    return beneficiary.id;
  }

  static BeneficiaryModel? getBeneficiary(String id) {
    return _beneficiariesBox!.get(id);
  }

  static List<BeneficiaryModel> getAllBeneficiaries() {
    return _beneficiariesBox!.values.toList();
  }

  static Future<void> updateBeneficiary(BeneficiaryModel beneficiary) async {
    await _beneficiariesBox!.put(beneficiary.id, beneficiary);
  }

  static Future<void> deleteBeneficiary(String id) async {
    await _beneficiariesBox!.delete(id);
  }

  // ==================== Zakat Records ====================

  static Future<String> addZakatRecord(ZakatRecordModel record) async {
    await _zakatRecordsBox!.put(record.id, record);
    return record.id;
  }

  static ZakatRecordModel? getZakatRecord(String id) {
    return _zakatRecordsBox!.get(id);
  }

  static List<ZakatRecordModel> getAllZakatRecords() {
    return _zakatRecordsBox!.values.toList()
      ..sort((a, b) => b.calculationDate.compareTo(a.calculationDate));
  }

  static Future<void> updateZakatRecord(ZakatRecordModel record) async {
    await _zakatRecordsBox!.put(record.id, record);
  }

  static Future<void> deleteZakatRecord(String id) async {
    await _zakatRecordsBox!.delete(id);
  }

  // ==================== Snapshots ====================

  static Future<String> addSnapshot(SnapshotModel snapshot) async {
    await _snapshotsBox!.put(snapshot.id, snapshot);
    return snapshot.id;
  }

  static SnapshotModel? getSnapshot(String id) {
    return _snapshotsBox!.get(id);
  }

  static List<SnapshotModel> getAllSnapshots() {
    return _snapshotsBox!.values.toList()
      ..sort((a, b) => b.year.compareTo(a.year));
  }

  static Future<void> updateSnapshot(SnapshotModel snapshot) async {
    await _snapshotsBox!.put(snapshot.id, snapshot);
  }

  static Future<void> deleteSnapshot(String id) async {
    await _snapshotsBox!.delete(id);
  }

  // ==================== Settings ====================

  static SettingsModel getSettings() {
    return _settingsBox!.get('default') ?? SettingsModel();
  }

  static Future<void> updateSettings(SettingsModel settings) async {
    await _settingsBox!.put('default', settings);
  }

  // ==================== Utility Methods ====================

  /// Calculate total outstanding balance for a loan
  static double calculateLoanOutstanding(String loanId) {
    final loan = getLoan(loanId);
    if (loan == null) return 0.0;

    final payments = getPaymentsByLoan(loanId);
    final totalPaid = payments.fold<double>(
      0.0,
      (sum, payment) => sum + payment.amount,
    );

    return loan.amount - totalPaid;
  }

  /// Calculate total outstanding for a borrower
  static double calculateBorrowerOutstanding(String borrowerId) {
    final loans = getLoansByBorrower(borrowerId);
    double total = 0.0;

    for (var loan in loans) {
      total += calculateLoanOutstanding(loan.id);
    }

    return total;
  }

  /// Get all loans for zakat calculation (only those with includeInZakat = true)
  static List<LoanModel> getActiveLoansForZakat() {
    return _loansBox!.values
        .where((loan) => loan.includeInZakat)
        .toList();
  }

  /// Calculate total receivables (active loans outstanding)
  static double calculateTotalReceivables() {
    final activeLoans = getActiveLoansForZakat();
    double total = 0.0;

    for (var loan in activeLoans) {
      total += calculateLoanOutstanding(loan.id);
    }

    return total;
  }

  /// Calculate total assets
  static double calculateTotalAssets() {
    return _assetsBox!.values.fold<double>(
      0.0,
      (sum, asset) => sum + asset.value,
    );
  }

  /// Calculate total liabilities (included in zakat)
  static double calculateTotalLiabilities() {
    return getIncludedLiabilities().fold<double>(
      0.0,
      (sum, liability) => sum + liability.amount,
    );
  }

  /// Clear all data (factory reset)
  static Future<void> clearAllData() async {
    await _borrowersBox!.clear();
    await _loansBox!.clear();
    await _paymentsBox!.clear();
    await _assetsBox!.clear();
    await _liabilitiesBox!.clear();
    await _beneficiariesBox!.clear();
    await _zakatRecordsBox!.clear();
    await _snapshotsBox!.clear();
    // Keep settings or reset to default
    await _initializeDefaultSettings();
  }

  /// Close all boxes
  static Future<void> close() async {
    await _borrowersBox?.close();
    await _loansBox?.close();
    await _paymentsBox?.close();
    await _assetsBox?.close();
    await _liabilitiesBox?.close();
    await _beneficiariesBox?.close();
    await _zakatRecordsBox?.close();
    await _snapshotsBox?.close();
    await _settingsBox?.close();
  }
}

