import 'package:get/get.dart';
import 'package:collection/collection.dart';
import '../../../models/borrower_model.dart';
import '../../../services/database_service.dart';

class BorrowerController extends GetxController {
  final borrowers = <BorrowerModel>[].obs;
  final filteredBorrowers = <BorrowerModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadBorrowers();
  }

  /// Load all borrowers from database
  Future<void> loadBorrowers() async {
    isLoading.value = true;
    try {
      final allBorrowers = DatabaseService.getAllBorrowers();
      borrowers.value = allBorrowers;
      borrowers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      filterBorrowers();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load borrowers: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter borrowers based on search query
  void filterBorrowers() {
    if (searchQuery.value.isEmpty) {
      filteredBorrowers.value = borrowers;
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredBorrowers.value = borrowers.where((borrower) {
        return borrower.name.toLowerCase().contains(query) ||
            (borrower.contactInfo?.toLowerCase().contains(query) ?? false) ||
            (borrower.address?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
  }

  /// Set search query and filter
  void setSearchQuery(String query) {
    searchQuery.value = query;
    filterBorrowers();
  }

  /// Add new borrower
  Future<bool> addBorrower({
    required String name,
    String? contactInfo,
    String? address,
    String? notes,
  }) async {
    try {
      final borrower = BorrowerModel(
        id: DatabaseService.generateId(),
        name: name.trim(),
        contactInfo: contactInfo?.trim(),
        address: address?.trim(),
        notes: notes?.trim(),
      );

      await DatabaseService.addBorrower(borrower);
      await loadBorrowers();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add borrower: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Update existing borrower
  Future<bool> updateBorrower(BorrowerModel borrower) async {
    try {
      final updated = borrower.copyWith(updatedAt: DateTime.now());
      await DatabaseService.updateBorrower(updated);
      await loadBorrowers();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update borrower: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Delete borrower
  Future<bool> deleteBorrower(String id) async {
    try {
      // Check if borrower has loans with outstanding balance
      final loans = DatabaseService.getLoansByBorrower(id);
      final loansWithOutstanding = loans.where((loan) {
        final outstanding = DatabaseService.calculateLoanOutstanding(loan.id);
        return outstanding > 0;
      }).toList();
      
      if (loansWithOutstanding.isNotEmpty) {
        Get.snackbar(
          'Cannot Delete',
          'This borrower has active loans. Please close or delete the loans first.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      await DatabaseService.deleteBorrower(id);
      await loadBorrowers();
      Get.snackbar(
        'Success',
        'Borrower deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete borrower: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Get borrower by ID
  BorrowerModel? getBorrowerById(String id) {
    return borrowers.firstWhereOrNull((b) => b.id == id);
  }

  /// Get total outstanding for a borrower
  double getBorrowerOutstanding(String borrowerId) {
    return DatabaseService.calculateBorrowerOutstanding(borrowerId);
  }
}

