import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/constants/app_colors.dart';
import 'package:kitty_app/core/errors/app_exception.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/core/theme/app_theme.dart';
import 'package:kitty_app/features/notifications/data/repositories/mock_notification_repository.dart';
import 'package:kitty_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:kitty_app/features/notifications/domain/repositories/i_notification_repository.dart';
import 'package:kitty_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:kitty_app/shared/widgets/buttons/kitty_primary_button.dart';
import 'package:kitty_app/shared/widgets/feedback/kitty_empty_state.dart';
import 'package:kitty_app/shared/widgets/feedback/kitty_error_state.dart';

class _EmptyNotificationRepository implements INotificationRepository {
  @override
  Future<List<NotificationEntity>> getNotifications({int page = 1, int limit = 20}) async => [];

  @override
  Future<int> getUnreadCount() async => 0;

  @override
  Future<void> markAllAsRead() async {}

  @override
  Future<void> markAsRead(String notificationId) async {}
}

class _FailingNotificationRepository implements INotificationRepository {
  @override
  Future<List<NotificationEntity>> getNotifications({int page = 1, int limit = 20}) async {
    throw const ServerException('Simulated notification network failure');
  }

  @override
  Future<int> getUnreadCount() async => 0;

  @override
  Future<void> markAllAsRead() async {}

  @override
  Future<void> markAsRead(String notificationId) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationsScreen Widget Tests (Phase 14)', () {
    late MockEngineConfig mockEngine;
    late MockNotificationRepository mockRepo;

    setUp(() {
      mockEngine = MockEngineConfig(latency: MockLatency.instant);
      mockRepo = MockNotificationRepository(engineConfig: mockEngine);
    });

    Widget createTestWidget([INotificationRepository? repository]) {
      return ProviderScope(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(repository ?? mockRepo),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const NotificationsScreen(),
        ),
      );
    }

    testWidgets('1. Renders sticky header and notifications list with unread indicators',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Title & Header Elements
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byKey(const Key('btn_notifications_back')), findsOneWidget);
      expect(find.byKey(const Key('btn_mark_all_read')), findsOneWidget);

      // Verify unread badge in header summary
      expect(find.text('Recent Alerts'), findsOneWidget);
      expect(find.text('3 unread'), findsOneWidget);

      // Verify notification tiles rendered
      expect(find.text('Month 8 Installment Verified 🎉'), findsOneWidget);
      expect(find.text('Month 9 EMI Due Reminder 🔔'), findsOneWidget);
      expect(find.text('Festive Making Charge Privileges ✨'), findsOneWidget);

      // Verify unread indicator dots exist for unread items
      expect(find.byKey(const Key('unread_indicator_dot')), findsNWidgets(3));
    });

    testWidgets('2. Tapping unread notification marks it read and opens detail sheet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap unread notification tile
      final unreadTile = find.byKey(const Key('notif_tile_notif_001'));
      expect(unreadTile, findsOneWidget);
      await tester.tap(unreadTile);
      await tester.pumpAndSettle();

      // Detail bottom sheet opens
      expect(find.text('Notification Details'), findsOneWidget);
      expect(find.text('Month 8 Installment Verified 🎉'), findsWidgets);
      expect(find.widgetWithText(KittyPrimaryButton, 'VIEW IN GOLD PASSBOOK'), findsOneWidget);

      // Dismiss detail sheet
      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();

      // Unread count decremented to 2
      expect(find.text('2 unread'), findsOneWidget);
      expect(find.byKey(const Key('unread_indicator_dot')), findsNWidgets(2));
    });

    testWidgets('3. Tapping Mark all read sets unread count to 0 and clears dots',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final markAllBtn = find.byKey(const Key('btn_mark_all_read'));
      expect(markAllBtn, findsOneWidget);
      await tester.tap(markAllBtn);
      await tester.pumpAndSettle();

      // All unread dots cleared
      expect(find.byKey(const Key('unread_indicator_dot')), findsNothing);
      // "Mark read" button disappears when unreadCount is 0
      expect(find.byKey(const Key('btn_mark_all_read')), findsNothing);
    });

    testWidgets('4. Empty notifications list displays KittyEmptyState',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(createTestWidget(_EmptyNotificationRepository()));
      await tester.pumpAndSettle();

      expect(find.byType(KittyEmptyState), findsOneWidget);
      expect(find.text('No Notifications Yet'), findsOneWidget);
    });

    testWidgets('5. Repository failure displays KittyErrorState with working retry',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(createTestWidget(_FailingNotificationRepository()));
      await tester.pumpAndSettle();

      expect(find.byType(KittyErrorState), findsOneWidget);
      expect(find.text('Unable to Load Notifications'), findsOneWidget);
      expect(find.text('Simulated notification network failure'), findsOneWidget);
      expect(find.widgetWithText(KittyPrimaryButton, 'TRY AGAIN'), findsOneWidget);
    });

    testWidgets('6. Renders Gold Scheme heading in honey gold and uses modern relevant icons',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Gold Scheme heading label
      final goldSchemeHeading = find.text('GOLD SCHEME');
      expect(goldSchemeHeading, findsOneWidget);
      final Text headingWidget = tester.widget<Text>(goldSchemeHeading);
      expect(headingWidget.style?.color, equals(AppColors.honeyGoldAccent));

      // Modern icons for notification types
      expect(find.byIcon(Icons.payments_rounded), findsOneWidget); // Transaction
      expect(find.byIcon(Icons.workspace_premium_rounded), findsOneWidget); // Gold Scheme
      expect(find.byIcon(Icons.loyalty_rounded), findsOneWidget); // Offer
      expect(find.byIcon(Icons.verified_user_rounded), findsOneWidget); // System
      expect(find.byIcon(Icons.notifications_active_rounded), findsOneWidget); // Unknown/Notice
    });
  });
}
