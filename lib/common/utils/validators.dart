class Validators {
  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Remove spaces, dashes, and parentheses
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validate amount (must be positive)
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid number';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  /// Validate positive number
  static String? validatePositiveNumber(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    if (number < 0) {
      return '${fieldName ?? 'Value'} must be 0 or greater';
    }
    return null;
  }

  /// Validate percentage (0-100)
  static String? validatePercentage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Percentage is required';
    }
    final percentage = double.tryParse(value);
    if (percentage == null) {
      return 'Please enter a valid number';
    }
    if (percentage < 0 || percentage > 100) {
      return 'Percentage must be between 0 and 100';
    }
    return null;
  }

  /// Validate date (must not be in future for certain cases)
  static String? validateDate(DateTime? date, {bool allowFuture = true}) {
    if (date == null) {
      return 'Date is required';
    }
    if (!allowFuture && date.isAfter(DateTime.now())) {
      return 'Date cannot be in the future';
    }
    return null;
  }

  /// Validate PIN (4-6 digits)
  static String? validatePIN(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN is required';
    }
    if (value.length < 4 || value.length > 6) {
      return 'PIN must be 4 to 6 digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'PIN must contain only digits';
    }
    return null;
  }

  /// Validate matching PINs
  static String? validatePINMatch(String? pin, String? confirmPin) {
    if (pin == null || pin.isEmpty) {
      return 'PIN is required';
    }
    if (confirmPin == null || confirmPin.isEmpty) {
      return 'Please confirm your PIN';
    }
    if (pin != confirmPin) {
      return 'PINs do not match';
    }
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    if (value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }
    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(String? value, int maxLength, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    if (value.length > maxLength) {
      return '${fieldName ?? 'This field'} must be at most $maxLength characters';
    }
    return null;
  }

  /// Combine multiple validators
  static String? validateMultiple(List<String? Function()> validators) {
    for (var validator in validators) {
      final result = validator();
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}

