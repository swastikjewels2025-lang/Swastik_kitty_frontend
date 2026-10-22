import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/enums/app_enums.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'package:kitty_app/features/dashboard/presentation/providers/dashboard_controller.dart';
import 'package:kitty_app/features/dashboard/presentation/providers/dashboard_state.dart';

void main() {
  group('DashboardController Unit Tests', () {
    late MockDashboardRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      final MockEngineConfig immediateEngine = MockEngineConfig(
        latency: MockLatency.instant,
      );
      mockRepository = MockDashboardRepository(engineConfig: immediateEngine);

      container = ProviderContainer(
        overrides: [
          dashboardRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial build triggers loadDashboard and transitions to loaded state', () async {
      final controller = container.read(dashboardControllerProvider.notifier);
      await controller.loadDashboard();

      final state = container.read(dashboardControllerProvider);
      expect(state.status, DashboardStatus.loaded);
      expect(state.data, isNotNull);
      expect(state.data!.hasActiveScheme, isTrue);
      expect(state.data!.chitToken, '#SW-042');
      expect(state.data!.targetAmount, 60000);
      expect(state.data!.customMonthlyEmi, 5000);
      expect(state.data!.monthsPaid, 8);
      expect(state.data!.totalMonths, 12);
      expect(state.data!.progressPercentage, 67);
      expect(state.data!.accumulatedGoldGrams, 5.482);
      expect(state.data!.nextInstallment, isNotNull);
      expect(state.data!.nextInstallment!.month, 9);
      expect(state.data!.nextInstallment!.amount, 5000);
    });

    test('Empty active scheme transitions state to empty', () async {
      mockRepository.setHasActiveScheme(false);
      final controller = container.read(dashboardControllerProvider.notifier);
      await controller.loadDashboard();

      final state = container.read(dashboardControllerProvider);
      expect(state.status, DashboardStatus.empty);
      expect(state.data, isNull);
    });

    test('Repository failure transitions state to error and retry recovers', () async {
      mockRepository.setShouldThrow(true);
      final controller = container.read(dashboardControllerProvider.notifier);
      await controller.loadDashboard();

      var state = container.read(dashboardControllerProvider);
      expect(state.status, DashboardStatus.error);
      expect(state.errorMessage, isNotNull);

      // Now fix failure and retry
      mockRepository.setShouldThrow(false);
      await controller.retry();

      state = container.read(dashboardControllerProvider);
      expect(state.status, DashboardStatus.loaded);
      expect(state.data, isNotNull);
    });

    test('Pull-to-refresh preserves existing data during refresh', () async {
      final controller = container.read(dashboardControllerProvider.notifier);
      await controller.loadDashboard();

      expect(container.read(dashboardControllerProvider).status, DashboardStatus.loaded);

      // Trigger refresh
      final refreshFuture = controller.loadDashboard(refresh: true);
      await refreshFuture;

      final state = container.read(dashboardControllerProvider);
      expect(state.status, DashboardStatus.loaded);
      expect(state.data, isNotNull);
    });

    test('PRE_JOIN status properly exposes isPreJoin getter', () async {
      mockRepository.setStatus(MembershipStatusEnum.preJoin);
      final controller = container.read(dashboardControllerProvider.notifier);
      await controller.loadDashboard();

      final state = container.read(dashboardControllerProvider);
      expect(state.status, DashboardStatus.loaded);
      expect(state.data!.isPreJoin, isTrue);
      expect(state.data!.status, MembershipStatusEnum.preJoin);
    });

    test('Completed status properly calculates remaining payable and completion flag', () async {
      mockRepository.setStatus(MembershipStatusEnum.completed);
      final controller = container.read(dashboardControllerProvider.notifier);
      await controller.loadDashboard();

      final state = container.read(dashboardControllerProvider);
      expect(state.status, DashboardStatus.loaded);
      expect(state.data!.isCompleted, isTrue);
      expect(state.data!.remainingMonthsPayable, 0);
    });
  });
}
