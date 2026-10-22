import 'phone_formatter.dart';

/// Centralized form field input validators for Kitty App.
abstract final class InputValidators {
  static final RegExp _indianPhoneRegex = RegExp(r'^[6-9]\d{9}$');
  static final RegExp _otpRegex = RegExp(r'^\d{6}$');
  static final RegExp _aadhaarRegex = RegExp(r'^\d{12}$');
  static final RegExp _panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');

  /// Validates standard 10-digit Indian mobile number starting with 6, 7, 8, or 9.
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required.';
    }
    final String cleaned = PhoneFormatter.clean(value);
    if (cleaned.length != 10) {
      return 'Please enter a valid 10-digit mobile number.';
    }
    if (!_indianPhoneRegex.hasMatch(cleaned)) {
      return 'Mobile number must start with 6, 7, 8, or 9.';
    }
    return null;
  }

  /// Validates 6-digit numeric OTP code.
  static String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the 6-digit OTP.';
    }
    final String cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (!_otpRegex.hasMatch(cleaned)) {
      return 'OTP must be exactly 6 numeric digits.';
    }
    return null;
  }

  /// Validates 12-digit UIDAI Indian Aadhaar number.
  static String? validateAadhaar(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Aadhaar number is required.';
    }
    final String cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (!_aadhaarRegex.hasMatch(cleaned)) {
      return 'Please enter a valid 12-digit Aadhaar number.';
    }
    return null;
  }

  /// Validates 10-character Indian Income Tax PAN.
  static String? validatePan(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PAN number is required.';
    }
    final String uppercase = value.trim().toUpperCase();
    if (!_panRegex.hasMatch(uppercase)) {
      return 'Please enter a valid 10-character PAN (e.g. ABCDE1234F).';
    }
    return null;
  }

  /// Validates required generic text field.
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }
}
