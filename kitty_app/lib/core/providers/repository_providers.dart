import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../mock/mock_engine_config.dart';
import '../network/dio_client.dart';
import 'core_providers.dart';

// Auth
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/auth/data/repositories/mock_auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';

// KYC
import '../../features/kyc/domain/repositories/i_kyc_repository.dart';
import '../../features/kyc/data/repositories/mock_kyc_repository.dart';
import '../../features/kyc/data/repositories/kyc_repository_impl.dart';

// Schemes & Offers
import '../../features/offers/domain/repositories/i_scheme_repository.dart';
import '../../features/offers/data/repositories/mock_scheme_repository.dart';
import '../../features/offers/data/repositories/scheme_repository_impl.dart';
import '../../features/offers/domain/repositories/i_offer_repository.dart';
import '../../features/offers/data/repositories/mock_offer_repository.dart';

// Dashboard & Passbook
import '../../features/dashboard/domain/repositories/i_dashboard_repository.dart';
import '../../features/dashboard/data/repositories/mock_dashboard_repository.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/i_membership_repository.dart';
import '../../features/dashboard/data/repositories/mock_membership_repository.dart';
import '../../features/passbook/domain/repositories/i_passbook_repository.dart';
import '../../features/passbook/data/repositories/mock_passbook_repository.dart';
import '../../features/passbook/data/repositories/passbook_repository_impl.dart';

// Payments
import '../../features/checkout/domain/repositories/i_payment_repository.dart';
import '../../features/checkout/data/repositories/mock_payment_repository.dart';
import '../../features/checkout/data/repositories/payment_repository_impl.dart';

// Home / Gold Rate / Products
import '../../features/home/domain/repositories/i_gold_rate_repository.dart';
import '../../features/home/data/repositories/mock_gold_rate_repository.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/i_product_repository.dart';
import '../../features/home/data/repositories/mock_product_repository.dart';

// Notifications
import '../../features/notifications/domain/repositories/i_notification_repository.dart';
import '../../features/notifications/data/repositories/mock_notification_repository.dart';

// Receipt
import '../../features/receipt/domain/repositories/i_receipt_repository.dart';
import '../../features/receipt/data/repositories/mock_receipt_repository.dart';

// Settings Profile & Local Settings
import '../../features/settings/domain/repositories/i_profile_repository.dart';
import '../../features/settings/data/repositories/mock_profile_repository.dart';
import '../../features/settings/data/repositories/profile_repository_impl.dart';
import '../../features/settings/domain/repositories/i_settings_local_repository.dart';
import '../../features/settings/data/repositories/settings_local_repository_impl.dart';
import '../storage/secure_storage_service.dart';

/// Provider for Mock Engine latency & failure simulation configuration.
final Provider<MockEngineConfig> mockEngineConfigProvider =
    Provider<MockEngineConfig>((Ref ref) {
  return MockEngineConfig();
});

/// Auth Repository Provider.
final Provider<IAuthRepository> authRepositoryProvider =
    Provider<IAuthRepository>((Ref ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  if (config.useMockApi) {
    final MockEngineConfig mockEngine = ref.watch(mockEngineConfigProvider);
    final storage = ref.watch(secureStorageServiceProvider);
    return MockAuthRepository(engineConfig: mockEngine, storageService: storage);
  }
  final DioClient dioClient = ref.watch(dioClientProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  return AuthRepositoryImpl(apiClient: dioClient, storageService: storage);
});

/// KYC Repository Provider.
final Provider<IKycRepository> kycRepositoryProvider =
    Provider<IKycRepository>((Ref ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  if (config.useMockApi) {
    final MockEngineConfig mockEngine = ref.watch(mockEngineConfigProvider);
    return MockKycRepository(engineConfig: mockEngine);
  }
  final DioClient dioClient = ref.watch(dioClientProvider);
  return KycRepositoryImpl(apiClient: dioClient);
});

/// Gold Schemes Repository Provider.
final Provider<ISchemeRepository> schemeRepositoryProvider =
    Provider<ISchemeRepository>((Ref ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  if (config.useMockApi) {
    final MockEngineConfig mockEngine = ref.watch(mockEngineConfigProvider);
    return MockSchemeRepository(engineConfig: mockEngine);
  }
  final DioClient dioClient = ref.watch(dioClientProvider);
  return SchemeRepositoryImpl(apiClient: dioClient);
});

/// Promotional Offers Repository Provider.
final Provider<IOfferRepository> offerRepositoryProvider =
    Provider<IOfferRepository>((Ref ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  if (config.useMockApi) {
    final MockEngineConfig mockEngine = ref.watch(mockEngineConfigProvider);
    return MockOfferRepository(engineConfig: mockEngine);
  }
  final DioClient dioClient = ref.watch(dioClientProvider);
  return SchemeRepositoryImpl(apiClient: dioClient);
});

/// Dashboard Summary Repository Provider.
final Provider<IDashboardRepository> dashboardRepositoryProvider =
    Provider<IDashboardRepository>((Ref ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  if (config.useMockApi) {
    final MockEngineConfig mockEngine = ref.watch(mockEngineConfigProvider);
    return MockDashboardRepository(engineConfig: mockEngine);
  }
  final DioClient dioClient = ref.watch(dioClientProvider);
  return DashboardRepositoryImpl(apiClient: dioClient);
});

/// Membership Repository Provider.
final Provider<IMembershipRepository> membershipRepositoryProvider =
    Provider<IMembershipRepository>((Ref ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  if (config.useMockApi) {
    final MockEngineConfig mockEngine = ref.watch(mockEngineConfigProvider);
    return MockMembershipRepository(engineConfig: mockEngine);
  }
  final DioClient dioClient = ref.watch(dioClientProvider);
  return DashboardRepositoryImpl(apiClient: dioClient);
});

/// Passbook & Installments Repository Provider.
final Provider<IPassbookRepository> passbookRepositoryProvider =
    Provider<IPassbookRepository>((Ref ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  if (config.useMockApi) {
    final MockEngineConfig mockEngine = ref.watch(mockEngineConfigProvider);
    return MockPassbookRepository(engineConfig: mockEngine);
  }
  final DioClient dioClient = ref.watch(dioClientProvider);
  return PassbookRepositoryImpl(apiClient: dioClient);
});

/// Payments Repository Provider.
final Provider<IPaymentRepository> paymentRepositoryProvider =
    Provider<IPaymentRepository>((Ref ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  if (config.useMockApi) {
    final MockEngineConfig mockEngine = ref.watch(mockEngineConfigProvider);
    return MockPaymentRepository(engineConfig: mockEngine);
  }
  final DioClient dioClient = ref.watch(dioClientProvider);
  return PaymentRepositoryImpl(apiClient: dioClient);
});

/// Live Gold Rate Repository Provider.
final Provider<IGoldRateRepository> goldRateRepositoryProvider =
    Provider<IGoldRateRepository>((Ref ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  if (config.useMockApi) {
    final MockEngineConfig mockEngine = ref.watch(mockEngineConfigProvider);
    return MockGoldRateRepository(engineConfig: mockEngine);
  }
  final DioClient dioClient = ref.watch(dioClientProvider);
  return HomeRepositoryImpl(apiClient: dioClient);
});

/// Products / Jewellery Catalog Repository Provider.
/// NOTE: The backend does not provide a products/jewellery catalog endpoint (the backend
/// is focused on kitty schemes and payments; jewellery is a design prototype showcase).
/// Kept explicitly on mock to prevent 404s even when [useMockApi] is false.
final Provider<IProductRepository> productRepositoryProvider =
    Provider<IProductRepository>((Ref ref) {
  final MockEngineConfig mockEngine = ref.watch(mockEngineConfigProvider);
  return MockProductRepository(engineConfig: mockEngine);
});

/// In-app Notifications Repository Provider.
/// NOTE: The backend has no in-app notification feed collection or REST endpoints.
/// Notifications are dispatched externally via SMS OTP / WhatsApp (Phase 14 verified gap).
/// Kept explicitly on mock to prevent 404s even when [useMockApi] is false.
final Provider<INotificationRepository> notificationRepositoryProvider =
    Provider<INotificationRepository>((Ref ref) {
  final MockEngineConfig mockEngine = ref.watch(mockEngineConfigProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  return MockNotificationRepository(
    engineConfig: mockEngine,
    storageService: storage,
  );
});

/// Payment Receipt Repository Provider.
/// NOTE: The backend generates receipts server-side (via pdfkit) and attaches
/// Cloudinary URLs directly to payments and passbook transactions. There is no `/api/v1/receipts` endpoint.
/// Kept explicitly on mock to safeguard against nonexistent route calls.
final Provider<IReceiptRepository> receiptRepositoryProvider =
    Provider<IReceiptRepository>((Ref ref) {
  final MockEngineConfig mockEngine = ref.watch(mockEngineConfigProvider);
  return MockReceiptRepository(engineConfig: mockEngine);
});

/// User Profile & Settings Repository Provider.
final Provider<IProfileRepository> profileRepositoryProvider =
    Provider<IProfileRepository>((Ref ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  if (config.useMockApi) {
    final MockEngineConfig mockEngine = ref.watch(mockEngineConfigProvider);
    return MockProfileRepository(engineConfig: mockEngine);
  }
  final DioClient dioClient = ref.watch(dioClientProvider);
  return ProfileRepositoryImpl(apiClient: dioClient);
});

/// Local Settings & Preferences Repository Provider.
final Provider<ISettingsLocalRepository> settingsLocalRepositoryProvider =
    Provider<ISettingsLocalRepository>((Ref ref) {
  final SecureStorageService storage = ref.watch(secureStorageServiceProvider);
  return SettingsLocalRepositoryImpl(storageService: storage);
});

