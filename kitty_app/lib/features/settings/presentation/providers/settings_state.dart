import 'package:flutter/foundation.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/profile_entity.dart';

/// Immutable state representation for the Patron Settings & Profile feature.
@immutable
class SettingsState {
  const SettingsState({
    this.isLoading = false,
    this.user,
    this.preferences = const UserPreferencesEntity(),
    this.hasMpin = false,
    this.errorMessage,
    this.isLoggingOut = false,
  });

  /// True while initial user profile or preferences are loading.
  final bool isLoading;

  /// Authenticated patron profile data (name, phone, tier, kyc, nominee).
  final UserEntity? user;

  /// Local preferences (biometrics, autoPay, themeMode, language).
  final UserPreferencesEntity preferences;

  /// True if a 4-digit transaction MPIN has been configured locally.
  final bool hasMpin;

  /// Present if an operation failed.
  final String? errorMessage;

  /// True during active sign-out teardown.
  final bool isLoggingOut;

  SettingsState copyWith({
    bool? isLoading,
    UserEntity? user,
    UserPreferencesEntity? preferences,
    bool? hasMpin,
    String? errorMessage,
    bool clearError = false,
    bool? isLoggingOut,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      preferences: preferences ?? this.preferences,
      hasMpin: hasMpin ?? this.hasMpin,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsState &&
        other.isLoading == isLoading &&
        other.user == user &&
        other.preferences.biometricEnabled == preferences.biometricEnabled &&
        other.preferences.autoPayEnabled == preferences.autoPayEnabled &&
        other.preferences.themeMode == preferences.themeMode &&
        other.preferences.language == preferences.language &&
        other.hasMpin == hasMpin &&
        other.errorMessage == errorMessage &&
        other.isLoggingOut == isLoggingOut;
  }

  @override
  int get hashCode => Object.hash(
        isLoading,
        user,
        preferences.biometricEnabled,
        preferences.autoPayEnabled,
        preferences.themeMode,
        preferences.language,
        hasMpin,
        errorMessage,
        isLoggingOut,
      );
}
