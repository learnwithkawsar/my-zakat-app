import 'package:get/get.dart';
import 'package:collection/collection.dart';
import '../../../models/loan_model.dart';
import '../../../models/borrower_model.dart';
import '../../../services/database_service.dart';

class LoanController extends GetxController {
  final loans = <LoanModel>[].obs;
  final filteredLoans = <LoanModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadLoans();
  }

  /// Load all loans from database
  Future<void> loadLoans() async {
    isLoading.value = true;
    try {
      final allLoans = DatabaseService.getAllLoans();
      loans.value = allLoans;
      loans.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      filterLoans();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load loans: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter loans based on search query
  void filterLoans() {
    var filtered = loans;

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((loan) {
        final borrower = DatabaseService.getBorrower(loan.borrowerId);
        return borrower?.name.toLowerCase().contains(query) ?? false ||
            (loan.notes != null && loan.notes!.toLowerCase().contains(query));
      }).toList().obs;
    }

    filteredLoans.value = filtered;
  }

  /// Set search query and filter
  void setSearchQuery(String query) {
    searchQuery.value = query;
    filterLoans();
  }

  /// Add new loan
  Future<bool> addLoan({
    required String borrowerId,
    required double amount,
    required DateTime transactionDate,
    DateTime? dueDate,
    String? notes,
    bool includeInZakat = true,
  }) async {
    try {
      final loan = LoanModel(
        id: DatabaseService.generateId(),
        borrowerId: borrowerId,
        amount: amount,
        transactionDate: transactionDate,
        dueDate: dueDate,
        notes: notes?.trim(),
        includeInZakat: includeInZakat,
      );

      await DatabaseService.addLoan(loan);
      await loadLoans();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add loan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Update existing loan
  Future<bool> updateLoan(LoanModel loan) async {
    try {
      final updated = loan.copyWith(updatedAt: DateTime.now());
      await DatabaseService.updateLoan(updated);
      await loadLoans();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update loan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Delete loan
  Future<bool> deleteLoan(String id) async {
    try {
      // Check if loan has payments
      final payments = DatabaseService.getPaymentsByLoan(id);
      if (payments.isNotEmpty) {
        Get.snackbar(
          'Cannot Delete',
          'This loan has payment records. Please delete the payments first.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      await DatabaseService.deleteLoan(id);
      await loadLoans();
      Get.snackbar(
        'Success',
        'Loan deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete loan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Get loan by ID
  LoanModel? getLoanById(String id) {
    return loans.firstWhereOrNull((l) => l.id == id);
  }

  /// Get loans by borrower
  List<LoanModel> getLoansByBorrower(String borrowerId) {
    return loans.where((l) => l.borrowerId == borrowerId).toList();
  }

  /// Calculate outstanding balance for a loan
  double getLoanOutstanding(String loanId) {
    return DatabaseService.calculateLoanOutstanding(loanId);
  }

  /// Toggle include in zakat
  Future<bool> toggleIncludeInZakat(String loanId) async {
    final loan = getLoanById(loanId);
    if (loan == null) return false;

    return await updateLoan(loan.copyWith(includeInZakat: !loan.includeInZakat));
  }

  /// Get total outstanding for all loans
  double getTotalOutstanding() {
    return loans.fold<double>(
      0.0,
      (sum, loan) => sum + getLoanOutstanding(loan.id),
    );
  }

  /// Get total loans count
  int getTotalLoansCount() {
    return loans.length;
  }
}

