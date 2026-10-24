import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/enums/app_enums.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/auth_state_provider.dart';
import 'package:kitty_app/core/providers/core_providers.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/core/storage/secure_storage_service.dart';
import 'package:kitty_app/features/offers/data/repositories/mock_scheme_repository.dart';
import 'package:kitty_app/features/offers/domain/entities/scheme_entity.dart';
import 'package:kitty_app/features/offers/presentation/screens/review_plan_screen.dart';

class _FakeSecureStorageService extends SecureStorageService {
  final Map<String, String> _map = <String, String>{};

  @override
  Future<void> write({required String key, required String value}) async {
    _map[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    return _map[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _map.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _map.clear();
  }
}

class _FakeAppAuthNotifier extends AppAuthNotifier {
  _FakeAppAuthNotifier(this._initialState);
  final AppAuthState _initialState;

  @override
  AppAuthState build() => _initialState;

  @override
  Future<void> checkAuthStatus() async {}
}

void main() {
  final MockEngineConfig instantConfig = MockEngineConfig(latency: MockLatency.instant);
  final _FakeSecureStorageService fakeStorage = _FakeSecureStorageService();

  const SchemeEntity shortScheme = SchemeEntity(
    id: 'scheme_short_1',
    name: 'ddd',
    targetAmount: 120000,
    durationMonths: 12,
    monthlyInstallment: 10000,
    maxCapacity: 50,
    currentMembers: 10,
    status: SchemeStatusEnum.open,
    benefits: ['Guaranteed bonus on completion'],
  );

  const SchemeEntity longScheme = SchemeEntity(
    id: 'scheme_long_1',
    name: 'Swastik Samriddhi 11+1 Plan',
    targetAmount: 30000,
    durationMonths: 6,
    monthlyInstallment: 5000,
    maxCapacity: 50,
    currentMembers: 15,
    status: SchemeStatusEnum.open,
    benefits: ['Guaranteed bonus on completion'],
  );

  const AppAuthState defaultAuthState = AppAuthState(
    userName: 'samarpan Singh',
    userPhone: '+918986464646',
    userEmail: 'samarpansign17@gmail.com',
    address: 'xkdodlckckck, dmdickcmcm',
    nomineeName: 'Not Registered',
    nomineeRelation: 'Beneficiary',
    nomineePhone: '-',
  );

  const AppAuthState longDataAuthState = AppAuthState(
    userName: 'Kumar Samarpanendra Vikramaditya Singh',
    userPhone: '+919876543210',
    userEmail: 'patron.verylongemailaddress1234567@organization.co.in',
    address: 'Flat 402, Royal Residency, Opp City Mall, S.G. Highway, Ahmedabad, Gujarat 380015',
    nomineeName: 'Priyadarshini Devi Samarpan Singh',
    nomineeRelation: 'Nominated Spouse / Legal Beneficiary',
    nomineePhone: '+919876543219',
  );

  Widget buildTestScreen({
    required SchemeEntity scheme,
    required String slot,
    AppAuthState authState = defaultAuthState,
  }) {
    return ProviderScope(
      overrides: [
        mockEngineConfigProvider.overrideWithValue(instantConfig),
        secureStorageServiceProvider.overrideWithValue(fakeStorage),
        schemeRepositoryProvider.overrideWithValue(MockSchemeRepository(engineConfig: instantConfig)),
        appAuthStateProvider.overrideWith(() => _FakeAppAuthNotifier(authState)),
      ],
      child: MaterialApp(
        home: ReviewPlanScreen(
          args: <String, dynamic>{
            'scheme': scheme,
            'selectedSlot': slot,
          },
        ),
      ),
    );
  }

  group('ReviewPlanScreen Responsiveness and Overflow Prevention Tests', () {
    testWidgets('1. Screenshot 1 case: Renders short scheme name "ddd" and bonus row without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestScreen(scheme: shortScheme, slot: '92'),
      );
      await tester.pumpAndSettle();

      // Header title and subtitle
      expect(find.text('Review Your Plan'), findsOneWidget);
      expect(find.text('Please review your scheme details and allocated slot before proceeding.'), findsOneWidget);

      // Card 1: Scheme Header
      expect(find.text('ddd'), findsOneWidget);
      expect(find.text('Edit'), findsNWidgets(3)); // 3 Edit buttons: Scheme, Patron, Nominee
      expect(find.byIcon(Icons.monetization_on_outlined), findsOneWidget);

      // Card 1: Rows
      expect(find.text('Allocated Chit Slot'), findsOneWidget);
      expect(find.text('#92'), findsOneWidget);
      expect(find.text('Monthly Installment'), findsOneWidget);
      expect(find.text('₹10000'), findsOneWidget);
      expect(find.text('Total Target Contribution'), findsOneWidget);
      expect(find.text('₹120000'), findsOneWidget);
      expect(find.text('Duration'), findsOneWidget);
      expect(find.text('12 Months'), findsOneWidget);
      expect(find.text('Installments Count'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('Bonus Eligibility'), findsOneWidget);
      expect(find.text('Guaranteed bonus on completion'), findsOneWidget);

      // Card 2: Patron Details
      expect(find.text('Patron Details'), findsOneWidget);
      expect(find.text('samarpan Singh'), findsOneWidget);
      expect(find.text('+918986464646'), findsOneWidget);

      // CTA button
      expect(find.text('Enroll & Proceed to Payment'), findsOneWidget);

      // Confirm zero exceptions occurred (no RenderFlex overflow)
      expect(tester.takeException(), isNull);
    });

    testWidgets('2. Screenshot 2 case: Long scheme title "Swastik Samriddhi 11+1 Plan" does not overlap Edit button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestScreen(scheme: longScheme, slot: '01'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Swastik Samriddhi 11+1 Plan'), findsOneWidget);
      expect(find.text('Edit'), findsNWidgets(3));

      // Verify scheme icon, title, and edit button geometry
      final Finder iconFinder = find.byIcon(Icons.monetization_on_outlined);
      final Finder titleFinder = find.text('Swastik Samriddhi 11+1 Plan');
      final Finder editFinder = find.text('Edit').first;

      final Rect iconRect = tester.getRect(iconFinder);
      final Rect titleRect = tester.getRect(titleFinder);
      final Rect editRect = tester.getRect(editFinder);

      // Title must start after icon
      expect(titleRect.left, greaterThanOrEqualTo(iconRect.right));
      // Edit button must be to the right of title without overlap
      expect(editRect.left, greaterThanOrEqualTo(titleRect.right - 1.0));

      expect(tester.takeException(), isNull);
    });

    testWidgets('3. Responsive Width Check: 320 logical pixels (narrow compact device)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320 * 2, 700 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestScreen(scheme: longScheme, slot: '92', authState: longDataAuthState),
      );
      await tester.pumpAndSettle();

      expect(find.text('Swastik Samriddhi 11+1 Plan'), findsOneWidget);
      expect(find.text('Bonus Eligibility'), findsOneWidget);
      expect(find.text('Guaranteed bonus on completion'), findsOneWidget);
      expect(find.text('Enroll & Proceed to Payment'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('4. Responsive Width Check: 360 logical pixels (standard Android device)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestScreen(scheme: longScheme, slot: '92', authState: longDataAuthState),
      );
      await tester.pumpAndSettle();

      expect(find.text('Swastik Samriddhi 11+1 Plan'), findsOneWidget);
      expect(find.text('Bonus Eligibility'), findsOneWidget);
      expect(find.text('Guaranteed bonus on completion'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('5. Responsive Width Check: 390 logical pixels (standard iPhone width)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestScreen(scheme: longScheme, slot: '92', authState: longDataAuthState),
      );
      await tester.pumpAndSettle();

      expect(find.text('Swastik Samriddhi 11+1 Plan'), findsOneWidget);
      expect(find.text('Bonus Eligibility'), findsOneWidget);
      expect(find.text('Guaranteed bonus on completion'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('6. Responsive Width Check: 430 logical pixels (large device width)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430 * 2, 932 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestScreen(scheme: longScheme, slot: '92', authState: longDataAuthState),
      );
      await tester.pumpAndSettle();

      expect(find.text('Swastik Samriddhi 11+1 Plan'), findsOneWidget);
      expect(find.text('Bonus Eligibility'), findsOneWidget);
      expect(find.text('Guaranteed bonus on completion'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('7. Patron Details with long email and multi-line address does not overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestScreen(scheme: shortScheme, slot: '05', authState: longDataAuthState),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kumar Samarpanendra Vikramaditya Singh'), findsOneWidget);
      expect(find.textContaining('patron'), findsOneWidget);
      expect(find.textContaining('Flat 402, Royal Residency'), findsOneWidget);
      expect(find.text('Priyadarshini Devi Samarpan Singh'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('8. Edit Scheme modal opens and renders plan options responsively',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestScreen(scheme: shortScheme, slot: '01'),
      );
      await tester.pumpAndSettle();

      // Tap first Edit button (Scheme header)
      await tester.tap(find.text('Edit').first);
      await tester.pumpAndSettle();

      expect(find.text('Select Plan Duration'), findsOneWidget);
      expect(find.text('6 Month Gold Plan'), findsOneWidget);
      expect(find.text('11 Month Gold Plan'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });
}
