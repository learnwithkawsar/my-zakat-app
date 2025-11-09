import 'package:get/get.dart';
import '../../../models/payment_model.dart';
import '../../../services/database_service.dart';

class PaymentController extends GetxController {
  final payments = <PaymentModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  /// Load payments for a specific loan
  Future<void> loadPaymentsByLoan(String loanId) async {
    isLoading.value = true;
    try {
      final loanPayments = DatabaseService.getPaymentsByLoan(loanId);
      payments.value = loanPayments;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load payments: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load all payments
  Future<void> loadAllPayments() async {
    isLoading.value = true;
    try {
      final allPayments = DatabaseService.getAllPayments();
      payments.value = allPayments;
      payments.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load payments: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Add payment for a specific loan
  Future<bool> addPayment({
    required String loanId,
    required double amount,
    required DateTime date,
    String? paymentType,
    String? notes,
  }) async {
    try {
      final loan = DatabaseService.getLoan(loanId);
      if (loan == null) {
        Get.snackbar(
          'Error',
          'Loan not found',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      // Validate that payment doesn't exceed outstanding balance
      final outstanding = DatabaseService.calculateLoanOutstanding(loanId);
      if (amount > outstanding) {
        Get.snackbar(
          'Error',
          'Payment amount cannot exceed outstanding balance',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final payment = PaymentModel(
        id: DatabaseService.generateId(),
        loanId: loanId,
        borrowerId: loan.borrowerId,
        amount: amount,
        date: date,
        paymentType: paymentType?.trim(),
        notes: notes?.trim(),
      );

      await DatabaseService.addPayment(payment);
      await loadPaymentsByLoan(loanId);
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add payment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Add borrower-level payment (applies to all borrower's loans proportionally)
  Future<bool> addBorrowerPayment({
    required String borrowerId,
    required double amount,
    required DateTime date,
    String? paymentType,
    String? notes,
  }) async {
    try {
      final loans = DatabaseService.getLoansByBorrower(borrowerId);
      if (loans.isEmpty) {
        Get.snackbar(
          'Error',
          'Borrower has no loans',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      // Calculate total outstanding for borrower
      final totalOutstanding = DatabaseService.calculateBorrowerOutstanding(borrowerId);
      if (amount > totalOutstanding) {
        Get.snackbar(
          'Error',
          'Payment amount cannot exceed total outstanding balance',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final payment = PaymentModel(
        id: DatabaseService.generateId(),
        loanId: null, // null means borrower-level payment
        borrowerId: borrowerId,
        amount: amount,
        date: date,
        paymentType: paymentType?.trim(),
        notes: notes?.trim(),
      );

      await DatabaseService.addPayment(payment);
      await loadPaymentsByBorrower(borrowerId);
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add payment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Update existing payment
  Future<bool> updatePayment(PaymentModel payment) async {
    try {
      if (payment.isForSpecificLoan) {
        // Validate loan-specific payment
        final loan = DatabaseService.getLoan(payment.loanId!);
        if (loan == null) {
          Get.snackbar(
            'Error',
            'Loan not found',
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }

        final existingPayments = DatabaseService.getPaymentsByLoan(payment.loanId!);
        final otherPaymentsTotal = existingPayments
            .where((p) => p.id != payment.id)
            .fold<double>(0.0, (sum, p) => sum + p.amount);

        // Calculate max allowed (considering borrower payments)
        final loanOutstandingWithoutBorrower = 
            DatabaseService.calculateLoanOutstandingWithoutBorrowerPayments(payment.loanId!);
        final maxAllowed = loanOutstandingWithoutBorrower + payment.amount - otherPaymentsTotal;

        if (payment.amount > maxAllowed) {
          Get.snackbar(
            'Error',
            'Total payments cannot exceed loan amount',
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }

        final updated = payment.copyWith(updatedAt: DateTime.now());
        await DatabaseService.updatePayment(updated);
        await loadPaymentsByLoan(payment.loanId!);
      } else {
        // Validate borrower-level payment
        final totalOutstanding = DatabaseService.calculateBorrowerOutstanding(payment.borrowerId);
        final existingBorrowerPayments = DatabaseService.getBorrowerLevelPayments(payment.borrowerId);
        final otherPaymentsTotal = existingBorrowerPayments
            .where((p) => p.id != payment.id)
            .fold<double>(0.0, (sum, p) => sum + p.amount);

        // Rough check - borrower payments are allocated proportionally
        if (payment.amount + otherPaymentsTotal > totalOutstanding + otherPaymentsTotal) {
          Get.snackbar(
            'Error',
            'Payment amount may exceed total outstanding',
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }

        final updated = payment.copyWith(updatedAt: DateTime.now());
        await DatabaseService.updatePayment(updated);
        await loadPaymentsByBorrower(payment.borrowerId);
      }
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update payment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Delete payment
  Future<bool> deletePayment(String id, {String? loanId, String? borrowerId}) async {
    try {
      final payment = DatabaseService.getPayment(id);
      if (payment == null) {
        Get.snackbar(
          'Error',
          'Payment not found',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      await DatabaseService.deletePayment(id);
      
      if (payment.isForSpecificLoan && loanId != null) {
        await loadPaymentsByLoan(loanId);
      } else if (borrowerId != null) {
        await loadPaymentsByBorrower(borrowerId);
      }
      
      Get.snackbar(
        'Success',
        'Payment deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete payment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Get payment by ID
  PaymentModel? getPaymentById(String id) {
    return payments.firstWhereOrNull((p) => p.id == id);
  }

  /// Load payments for a specific borrower
  Future<void> loadPaymentsByBorrower(String borrowerId) async {
    isLoading.value = true;
    try {
      final borrowerPayments = DatabaseService.getPaymentsByBorrower(borrowerId);
      payments.value = borrowerPayments;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load payments: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get total payments for a loan
  double getTotalPaymentsForLoan(String loanId) {
    return payments
        .where((p) => p.loanId == loanId)
        .fold<double>(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Get total payments for a borrower
  double getTotalPaymentsForBorrower(String borrowerId) {
    final borrowerPayments = DatabaseService.getPaymentsByBorrower(borrowerId);
    return borrowerPayments.fold<double>(
      0.0,
      (sum, payment) => sum + payment.amount,
    );
  }
}

