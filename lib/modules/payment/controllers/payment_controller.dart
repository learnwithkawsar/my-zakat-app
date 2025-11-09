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

  /// Add new payment
  Future<bool> addPayment({
    required String loanId,
    required double amount,
    required DateTime date,
    String? paymentType,
    String? notes,
  }) async {
    try {
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

  /// Update existing payment
  Future<bool> updatePayment(PaymentModel payment) async {
    try {
      // Validate that payment doesn't exceed outstanding balance
      final loan = DatabaseService.getLoan(payment.loanId);
      if (loan == null) {
        Get.snackbar(
          'Error',
          'Loan not found',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final existingPayments = DatabaseService.getPaymentsByLoan(payment.loanId);
      final otherPaymentsTotal = existingPayments
          .where((p) => p.id != payment.id)
          .fold<double>(0.0, (sum, p) => sum + p.amount);

      if (payment.amount + otherPaymentsTotal > loan.amount) {
        Get.snackbar(
          'Error',
          'Total payments cannot exceed loan amount',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final updated = payment.copyWith(updatedAt: DateTime.now());
      await DatabaseService.updatePayment(updated);
      await loadPaymentsByLoan(payment.loanId);
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
  Future<bool> deletePayment(String id, String loanId) async {
    try {
      await DatabaseService.deletePayment(id);
      await loadPaymentsByLoan(loanId);
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

  /// Get total payments for a loan
  double getTotalPaymentsForLoan(String loanId) {
    return payments
        .where((p) => p.loanId == loanId)
        .fold<double>(0.0, (sum, payment) => sum + payment.amount);
  }
}

