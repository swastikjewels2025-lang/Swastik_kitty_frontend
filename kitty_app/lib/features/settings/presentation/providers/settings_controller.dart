import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/repositories/i_auth_repository.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/i_settings_local_repository.dart';
import 'settings_state.dart';

/// State notifier managing user profile loading, settings toggles, and theme synchronization.
class SettingsController extends Notifier<SettingsState> {
  late IAuthRepository _authRepository;
  late ISettingsLocalRepository _settingsRepository;

  @override
  SettingsState build() {
    _authRepository = ref.watch(authRepositoryProvider);
    _settingsRepository = ref.watch(settingsLocalRepositoryProvider);

    // Asynchronously load user profile & local settings after build completes
    Future.microtask(loadInitialData);

    final AppAuthState authState = ref.read(appAuthStateProvider);
    UserEntity? initialUser;
    if (authState.isAuthenticated) {
      initialUser = UserEntity(
        id: 'patron_active',
        name: authState.userName,
        phone: authState.userPhone,
        role: UserRoleEnum.customer,
        tier: authState.tier,
        createdAt: DateTime(2024, 1, 1),
      );
    }

    return SettingsState(
      isLoading: true,
      user: initialUser,
    );
  }

  /// Fetches canonical user profile from backend/mock and local preferences from storage.
  Future<void> loadInitialData() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final UserPreferencesEntity preferences = await _settingsRepository.getPreferences();
      if (!ref.mounted) return;
      final bool hasMpin = await _settingsRepository.hasMpin();
      if (!ref.mounted) return;

      UserEntity? user;
      try {
        user = await _authRepository.getCurrentUser();
      } catch (_) {
        // In unauthenticated or offline fallback, continue gracefully with local state
      }
      if (!ref.mounted) return;

      state = state.copyWith(
        isLoading: false,
        user: user,
        preferences: preferences,
        hasMpin: hasMpin,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load profile settings.',
      );
    }
  }

  /// Toggles local biometric lock preference.
  Future<void> toggleBiometric(bool enabled) async {
    final UserPreferencesEntity updated = state.preferences.copyWith(biometricEnabled: enabled);
    state = state.copyWith(preferences: updated);
    await _settingsRepository.setBiometricEnabled(enabled);
  }

  /// Toggles UPI AutoPay / e-Mandate preference.
  Future<void> toggleAutoPay(bool enabled) async {
    final UserPreferencesEntity updated = state.preferences.copyWith(autoPayEnabled: enabled);
    state = state.copyWith(preferences: updated);
    await _settingsRepository.setAutoPayEnabled(enabled);
  }

  /// Updates application theme mode preference ('system', 'dark', 'light').
  Future<void> setThemeMode(String themeMode) async {
    final UserPreferencesEntity updated = state.preferences.copyWith(themeMode: themeMode);
    state = state.copyWith(preferences: updated);
    await _settingsRepository.setThemeMode(themeMode);
  }

  /// Updates application language preference ('en', 'hi', etc.).
  Future<void> setLanguage(String language) async {
    final UserPreferencesEntity updated = state.preferences.copyWith(language: language);
    state = state.copyWith(preferences: updated);
    await _settingsRepository.setLanguage(language);
  }

  /// Persists new 4-digit transaction MPIN.
  Future<void> setMpin(String mpin) async {
    await _settingsRepository.setMpin(mpin);
    state = state.copyWith(hasMpin: true);
  }

  /// Verifies candidate MPIN against securely hashed storage.
  Future<bool> verifyMpin(String candidate) async {
    return _settingsRepository.verifyMpin(candidate);
  }

  /// Clears session and logs user out of the app.
  Future<void> logout() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoggingOut: true);
    try {
      await ref.read(appAuthStateProvider.notifier).logout();
    } finally {
      if (ref.mounted) {
        state = state.copyWith(isLoggingOut: false);
      }
    }
  }
}

/// Provider for [SettingsController].
final NotifierProvider<SettingsController, SettingsState> settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);

/// Provider exposing [ThemeMode] synchronized with active [SettingsController] preferences.
final Provider<ThemeMode> themeModeProvider = Provider<ThemeMode>((Ref ref) {
  final SettingsState settings = ref.watch(settingsControllerProvider);
  switch (settings.preferences.themeMode) {
    case 'dark':
      return ThemeMode.dark;
    case 'light':
      return ThemeMode.light;
    case 'system':
    default:
      return ThemeMode.system;
  }
});
