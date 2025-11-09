import 'package:get/get.dart';
import '../../../models/settings_model.dart';
import '../../../services/database_service.dart';

class SettingsController extends GetxController {
  final isLoading = false.obs;
  final settings = Rxn<SettingsModel>();

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  /// Load settings from database
  void loadSettings() {
    settings.value = DatabaseService.getSettings();
  }

  /// Update settings
  Future<bool> updateSettings(SettingsModel newSettings) async {
    isLoading.value = true;
    try {
      await DatabaseService.updateSettings(newSettings);
      settings.value = newSettings;
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update currency
  Future<bool> updateCurrency(String currency) async {
    if (settings.value == null) return false;
    final updated = settings.value!.copyWith(currency: currency);
    return await updateSettings(updated);
  }

  /// Update zakat rate
  Future<bool> updateZakatRate(double rate) async {
    if (settings.value == null) return false;
    final updated = settings.value!.copyWith(zakatRate: rate);
    return await updateSettings(updated);
  }

  /// Update nisab
  Future<bool> updateNisab(double nisab) async {
    if (settings.value == null) return false;
    final updated = settings.value!.copyWith(nisab: nisab);
    return await updateSettings(updated);
  }

  /// Update gold price per gram
  Future<bool> updateGoldPricePerGram(double price) async {
    if (settings.value == null) return false;
    final updated = settings.value!.copyWith(goldPricePerGram: price);
    return await updateSettings(updated);
  }

  /// Update silver price per gram
  Future<bool> updateSilverPricePerGram(double price) async {
    if (settings.value == null) return false;
    final updated = settings.value!.copyWith(silverPricePerGram: price);
    return await updateSettings(updated);
  }

  /// Update reminder date
  Future<bool> updateReminderDate(DateTime? date) async {
    if (settings.value == null) return false;
    final updated = settings.value!.copyWith(reminderDate: date);
    return await updateSettings(updated);
  }

  /// Toggle biometric
  Future<bool> toggleBiometric(bool enabled) async {
    if (settings.value == null) return false;
    final updated = settings.value!.copyWith(useBiometric: enabled);
    return await updateSettings(updated);
  }

  /// Update auto lock timeout
  Future<bool> updateAutoLockTimeout(int minutes) async {
    if (settings.value == null) return false;
    final updated = settings.value!.copyWith(autoLockTimeoutMinutes: minutes);
    return await updateSettings(updated);
  }
}

