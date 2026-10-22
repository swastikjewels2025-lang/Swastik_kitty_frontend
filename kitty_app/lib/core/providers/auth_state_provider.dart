import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage_service.dart';
import 'core_providers.dart';

/// Status enumeration for application authentication state.
enum AuthStatus {
  /// App is booting; verifying local token in SecureStorage.
  initial,

  /// User is verified with an active 30-day JWT Bearer token.
  authenticated,

  /// No valid JWT exists in SecureStorage.
  unauthenticated,
}

/// Immutable state representation of the user's authentication and session.
@immutable
class AppAuthState {
  const AppAuthState({
    this.status = AuthStatus.initial,
    this.token,
    this.userName = '',
    this.userPhone = '',
    this.userEmail = '',
    this.userDob = '',
    this.address = '',
    this.city = '',
    this.pincode = '',
    this.nomineeName = '',
    this.nomineeRelation = '',
    this.nomineePhone = '',
    this.tier = 'Standard Member',
    this.isKycVerified = false,
    this.isOnboarded = false,
    this.hasSkippedKyc = false,
    this.photoPath,
  });

  const AppAuthState.initial() : this(status: AuthStatus.initial);

  const AppAuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  const AppAuthState.authenticated({
    required String token,
    String userName = '',
    String userPhone = '',
    String userEmail = '',
    String userDob = '',
    String address = '',
    String city = '',
    String pincode = '',
    String nomineeName = '',
    String nomineeRelation = '',
    String nomineePhone = '',
    String tier = 'Standard Member',
    bool isKycVerified = false,
    bool isOnboarded = false,
    bool hasSkippedKyc = false,
    String? photoPath,
  }) : this(
          status: AuthStatus.authenticated,
          token: token,
          userName: userName,
          userPhone: userPhone,
          userEmail: userEmail,
          userDob: userDob,
          address: address,
          city: city,
          pincode: pincode,
          nomineeName: nomineeName,
          nomineeRelation: nomineeRelation,
          nomineePhone: nomineePhone,
          tier: tier,
          isKycVerified: isKycVerified,
          isOnboarded: isOnboarded,
          hasSkippedKyc: hasSkippedKyc,
          photoPath: photoPath,
        );

  final AuthStatus status;
  final String? token;
  final String userName;
  final String userPhone;
  final String userEmail;
  final String userDob;
  final String address;
  final String city;
  final String pincode;
  final String nomineeName;
  final String nomineeRelation;
  final String nomineePhone;
  final String tier;
  final bool isKycVerified;
  final bool isOnboarded;
  final bool hasSkippedKyc;
  final String? photoPath;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isInitial => status == AuthStatus.initial;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  AppAuthState copyWith({
    AuthStatus? status,
    String? token,
    String? userName,
    String? userPhone,
    String? userEmail,
    String? userDob,
    String? address,
    String? city,
    String? pincode,
    String? nomineeName,
    String? nomineeRelation,
    String? nomineePhone,
    String? tier,
    bool? isKycVerified,
    bool? isOnboarded,
    bool? hasSkippedKyc,
    String? photoPath,
  }) {
    return AppAuthState(
      status: status ?? this.status,
      token: token ?? this.token,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      userEmail: userEmail ?? this.userEmail,
      userDob: userDob ?? this.userDob,
      address: address ?? this.address,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      nomineeName: nomineeName ?? this.nomineeName,
      nomineeRelation: nomineeRelation ?? this.nomineeRelation,
      nomineePhone: nomineePhone ?? this.nomineePhone,
      tier: tier ?? this.tier,
      isKycVerified: isKycVerified ?? this.isKycVerified,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      hasSkippedKyc: hasSkippedKyc ?? this.hasSkippedKyc,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppAuthState &&
        other.status == status &&
        other.token == token &&
        other.userName == userName &&
        other.userPhone == userPhone &&
        other.userEmail == userEmail &&
        other.userDob == userDob &&
        other.address == address &&
        other.city == city &&
        other.pincode == pincode &&
        other.nomineeName == nomineeName &&
        other.nomineeRelation == nomineeRelation &&
        other.nomineePhone == nomineePhone &&
        other.tier == tier &&
        other.isKycVerified == isKycVerified &&
        other.isOnboarded == isOnboarded &&
        other.hasSkippedKyc == hasSkippedKyc &&
        other.photoPath == photoPath;
  }

  @override
  int get hashCode => Object.hash(
        status,
        token,
        userName,
        userPhone,
        userEmail,
        userDob,
        address,
        city,
        pincode,
        nomineeName,
        nomineeRelation,
        nomineePhone,
        tier,
        isKycVerified,
        isOnboarded,
        hasSkippedKyc,
        photoPath,
      );
}

/// State notifier managing session authentication state.
class AppAuthNotifier extends Notifier<AppAuthState> {
  late final SecureStorageService _storage;

  @override
  AppAuthState build() {
    _storage = ref.watch(secureStorageServiceProvider);
    // Asynchronously check stored token on initial build
    unawaited(checkAuthStatus());
    return const AppAuthState.initial();
  }

  /// Verifies whether an active token is stored in SecureStorage.
  Future<void> checkAuthStatus() async {
    try {
      final String? token = await _storage.getToken();
      if (token != null && token.trim().isNotEmpty) {
        String userName = '';
        String userPhone = '';
        String userEmail = '';
        String userDob = '';
        String address = '';
        String city = '';
        String pincode = '';
        String nomineeName = '';
        String nomineeRelation = '';
        String nomineePhone = '';
        String tier = 'Standard Member';
        bool isKyc = false;
        bool isOnboarded = false;
        bool hasSkippedKyc = false;

        String? photoPath;

        final String? userJson = await _storage.getUserData();
        if (userJson != null && userJson.trim().isNotEmpty) {
          try {
            final Map<String, dynamic> data = jsonDecode(userJson) as Map<String, dynamic>;
            final String? storedName = data['name'] as String?;
            if (storedName != null && storedName.isNotEmpty && storedName != 'Patron' && storedName != 'Rihan') {
              userName = storedName;
            }
            if (data['phone'] is String && (data['phone'] as String).isNotEmpty) {
              userPhone = data['phone'] as String;
            }
            final String? storedEmail = data['email'] as String?;
            if (storedEmail != null && storedEmail.isNotEmpty && storedEmail != 'rihan@swastikjewel.com') {
              userEmail = storedEmail;
            }
            if (data['dob'] is String && (data['dob'] as String).isNotEmpty) {
              userDob = data['dob'] as String;
            }
            if (data['address'] is String && (data['address'] as String).isNotEmpty) {
              address = data['address'] as String;
            }
            if (data['city'] is String && (data['city'] as String).isNotEmpty) {
              city = data['city'] as String;
            }
            if (data['pincode'] is String && (data['pincode'] as String).isNotEmpty) {
              pincode = data['pincode'] as String;
            }
            if (data['nomineeName'] is String && (data['nomineeName'] as String).isNotEmpty) {
              nomineeName = data['nomineeName'] as String;
            }
            if (data['nomineeRelation'] is String && (data['nomineeRelation'] as String).isNotEmpty) {
              nomineeRelation = data['nomineeRelation'] as String;
            }
            if (data['nomineePhone'] is String && (data['nomineePhone'] as String).isNotEmpty) {
              nomineePhone = data['nomineePhone'] as String;
            }
            if (data['tier'] is String && (data['tier'] as String).isNotEmpty) {
              tier = data['tier'] as String;
            }
            if (data['photoPath'] is String && (data['photoPath'] as String).isNotEmpty) {
              photoPath = data['photoPath'] as String;
            }
            if (data['isOnboarded'] is bool) {
              isOnboarded = data['isOnboarded'] as bool;
            }
            if (data['hasSkippedKyc'] is bool) {
              hasSkippedKyc = data['hasSkippedKyc'] as bool;
            }
            if (data['kyc'] is Map<String, dynamic>) {
              final Map<String, dynamic> kyc = data['kyc'] as Map<String, dynamic>;
              isKyc = kyc['isVerified'] == true || kyc['status'] == 'VERIFIED';
            }
          } catch (_) {}
        }

        // Live backend profile sync
        try {
          final DioClient dio = ref.read(dioClientProvider);
          final dynamic profileRes = await dio.get<Map<String, dynamic>>('/api/v1/users/profile');
          final dynamic rawData = profileRes.data?['data'];
          final Map<String, dynamic>? userRemote = (rawData?['user'] ?? rawData) as Map<String, dynamic>?;
          if (userRemote != null) {
            final String? remoteName = userRemote['name'] as String?;
            if (remoteName != null && remoteName.isNotEmpty && remoteName != 'Patron' && remoteName != 'Rihan') {
              userName = remoteName;
              isOnboarded = true;
            }
            final String? remotePhone = userRemote['phone'] as String?;
            if (remotePhone != null && remotePhone.isNotEmpty) {
              userPhone = remotePhone;
            }
            final String? remoteEmail = userRemote['email'] as String?;
            if (remoteEmail != null && remoteEmail.isNotEmpty && remoteEmail != 'rihan@swastikjewel.com') {
              userEmail = remoteEmail;
            }
            final String? remoteAddr = userRemote['address'] as String?;
            if (remoteAddr != null && remoteAddr.isNotEmpty) {
              address = remoteAddr;
            }
            final String? remoteCity = userRemote['city'] as String?;
            if (remoteCity != null && remoteCity.isNotEmpty) {
              city = remoteCity;
            }
            final String? remotePin = userRemote['pincode'] as String?;
            if (remotePin != null && remotePin.isNotEmpty) {
              pincode = remotePin;
            }
            if (userRemote['nominee'] is Map<String, dynamic>) {
              final Map<String, dynamic> nom = userRemote['nominee'] as Map<String, dynamic>;
              nomineeName = nom['name'] as String? ?? nomineeName;
              nomineeRelation = nom['relationship'] as String? ?? nomineeRelation;
              nomineePhone = nom['phone'] as String? ?? nomineePhone;
            } else {
              nomineeName = userRemote['nomineeName'] as String? ?? nomineeName;
              nomineeRelation = userRemote['nomineeRelationship'] as String? ?? nomineeRelation;
              nomineePhone = userRemote['nomineePhone'] as String? ?? nomineePhone;
            }
            if (userRemote['kyc'] is Map<String, dynamic>) {
              final Map<String, dynamic> kyc = userRemote['kyc'] as Map<String, dynamic>;
              isKyc = kyc['isVerified'] == true || kyc['status'] == 'VERIFIED';
            }
          }
        } catch (_) {}

        state = AppAuthState.authenticated(
          token: token,
          userName: userName,
          userPhone: userPhone,
          userEmail: userEmail,
          userDob: userDob,
          address: address,
          city: city,
          pincode: pincode,
          nomineeName: nomineeName,
          nomineeRelation: nomineeRelation,
          nomineePhone: nomineePhone,
          tier: tier,
          isKycVerified: isKyc,
          isOnboarded: isOnboarded,
          hasSkippedKyc: hasSkippedKyc,
          photoPath: photoPath,
        );
      } else {
        state = const AppAuthState.unauthenticated();
      }
    } catch (_) {
      state = const AppAuthState.unauthenticated();
    }
  }

  /// Sets session to authenticated and stores token in SecureStorage.
  Future<void> setAuthenticated({
    required String token,
    String userName = '',
    String userPhone = '',
    String userEmail = '',
    String userDob = '',
    String address = '',
    String city = '',
    String pincode = '',
    String nomineeName = '',
    String nomineeRelation = '',
    String nomineePhone = '',
    String tier = 'Standard Member',
    bool isKycVerified = false,
    bool isOnboarded = false,
  }) async {
    await _storage.saveToken(token);
    state = AppAuthState.authenticated(
      token: token,
      userName: userName,
      userPhone: userPhone,
      userEmail: userEmail,
      userDob: userDob,
      address: address,
      city: city,
      pincode: pincode,
      nomineeName: nomineeName,
      nomineeRelation: nomineeRelation,
      nomineePhone: nomineePhone,
      tier: tier,
      isKycVerified: isKycVerified,
      isOnboarded: isOnboarded,
    );
  }

  /// Updates user profile details (Name, Email, Phone, DOB, Address, City, Pincode, Nominee, Photo) and persists them.
  Future<void> updateProfile({
    required String userName,
    String? userEmail,
    String? userPhone,
    String? userDob,
    String? address,
    String? city,
    String? pincode,
    String? nomineeName,
    String? nomineeRelation,
    String? nomineePhone,
    String? photoPath,
    bool? isOnboarded,
  }) async {
    final String currentPhone = (userPhone != null && userPhone.isNotEmpty)
        ? userPhone
        : state.userPhone;
    final String currentEmail = (userEmail != null && userEmail.isNotEmpty)
        ? userEmail
        : state.userEmail;
    final String currentDob = (userDob != null && userDob.isNotEmpty)
        ? userDob
        : state.userDob;
    final String currentAddress = address ?? state.address;
    final String currentCity = city ?? state.city;
    final String currentPincode = pincode ?? state.pincode;
    final String currentNomName = nomineeName ?? state.nomineeName;
    final String currentNomRel = nomineeRelation ?? state.nomineeRelation;
    final String currentNomPhone = nomineePhone ?? state.nomineePhone;
    final String? currentPhotoPath = photoPath ?? state.photoPath;
    final bool currentOnboarded = isOnboarded ?? state.isOnboarded;

    state = state.copyWith(
      userName: userName,
      userPhone: currentPhone,
      userEmail: currentEmail,
      userDob: currentDob,
      address: currentAddress,
      city: currentCity,
      pincode: currentPincode,
      nomineeName: currentNomName,
      nomineeRelation: currentNomRel,
      nomineePhone: currentNomPhone,
      photoPath: currentPhotoPath,
      isOnboarded: currentOnboarded,
    );

    // Persist to SecureStorage safely
    try {
      final Map<String, dynamic> userData = <String, dynamic>{
        'name': userName,
        'email': currentEmail,
        'phone': currentPhone,
        'dob': currentDob,
        'address': currentAddress,
        'city': currentCity,
        'pincode': currentPincode,
        'nomineeName': currentNomName,
        'nomineeRelation': currentNomRel,
        'nomineePhone': currentNomPhone,
        'tier': state.tier,
        'photoPath': currentPhotoPath ?? '',
        'isOnboarded': currentOnboarded,
        'kyc': <String, dynamic>{
          'isVerified': state.isKycVerified,
          'status': state.isKycVerified ? 'VERIFIED' : 'PENDING',
        },
      };
      await _storage.saveUserData(jsonEncode(userData)).timeout(
            const Duration(milliseconds: 200),
            onTimeout: () {},
          );
    } catch (_) {}

    // Dispatch live update to backend MongoDB user profile
    try {
      final DioClient dio = ref.read(dioClientProvider);
      await dio.put<Map<String, dynamic>>(
        '/api/v1/users/profile',
        data: <String, dynamic>{
          'name': userName.trim(),
          if (currentEmail.isNotEmpty) 'email': currentEmail.trim(),
          if (currentDob.isNotEmpty) 'dateOfBirth': currentDob.trim(),
          if (currentAddress.isNotEmpty) 'address': currentAddress.trim(),
          if (currentCity.isNotEmpty) 'city': currentCity.trim(),
          if (currentPincode.isNotEmpty) 'pincode': currentPincode.trim(),
          'nominee': <String, dynamic>{
            'name': currentNomName.trim(),
            'relationship': currentNomRel.trim(),
            'phone': currentNomPhone.trim(),
          },
        },
      );
    } catch (_) {}
  }

  /// Marks KYC as complete and finishes user onboarding.
  Future<void> completeKyc() async {
    state = state.copyWith(
      isKycVerified: true,
      isOnboarded: true,
      hasSkippedKyc: false,
    );

    try {
      final String? userJson = await _storage.getUserData();
      Map<String, dynamic> userData = <String, dynamic>{};
      if (userJson != null && userJson.trim().isNotEmpty) {
        try {
          userData = jsonDecode(userJson) as Map<String, dynamic>;
        } catch (_) {}
      }
      userData['isOnboarded'] = true;
      userData['hasSkippedKyc'] = false;
      userData['kyc'] = <String, dynamic>{
        'isVerified': true,
        'status': 'VERIFIED',
      };
      await _storage.saveUserData(jsonEncode(userData));
    } catch (_) {}
  }

  /// Allows the patron to skip KYC for now to explore gold schemes & jewellery,
  /// preserving their pending statutory compliance status.
  Future<void> skipKyc() async {
    state = state.copyWith(
      hasSkippedKyc: true,
      isOnboarded: true,
    );

    try {
      final String? userJson = await _storage.getUserData();
      Map<String, dynamic> userData = <String, dynamic>{};
      if (userJson != null && userJson.trim().isNotEmpty) {
        try {
          userData = jsonDecode(userJson) as Map<String, dynamic>;
        } catch (_) {}
      }
      userData['isOnboarded'] = true;
      userData['hasSkippedKyc'] = true;
      await _storage.saveUserData(jsonEncode(userData));
    } catch (_) {}
  }


  /// Clears secure session and transitions state to unauthenticated.
  Future<void> logout() async {
    await _storage.clearSession();
    state = const AppAuthState.unauthenticated();
  }
}

/// Provider for application authentication state.
final NotifierProvider<AppAuthNotifier, AppAuthState> appAuthStateProvider =
    NotifierProvider<AppAuthNotifier, AppAuthState>(AppAuthNotifier.new);

/// A [ChangeNotifier] bridge that triggers GoRouter redirect re-evaluations
/// whenever [appAuthStateProvider] updates.
class AuthRouterListenable extends ChangeNotifier {
  AuthRouterListenable(Ref ref) {
    ref.listen<AppAuthState>(appAuthStateProvider, (AppAuthState? previous, AppAuthState next) {
      notifyListeners();
    });
  }
}

/// Provider for the [AuthRouterListenable] bridge.
final Provider<AuthRouterListenable> authRouterListenableProvider =
    Provider<AuthRouterListenable>((Ref ref) {
  return AuthRouterListenable(ref);
});
