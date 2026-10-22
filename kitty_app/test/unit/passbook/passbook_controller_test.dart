import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/passbook/data/repositories/mock_passbook_repository.dart';
import 'package:kitty_app/features/passbook/presentation/providers/passbook_controller.dart';
import 'package:kitty_app/features/passbook/presentation/providers/passbook_state.dart';

void main() {
  group('PassbookController Unit Tests', () {
    late MockPassbookRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      final MockEngineConfig immediateEngine = MockEngineConfig(
        latency: MockLatency.instant,
      );
      mockRepository = MockPassbookRepository(engineConfig: immediateEngine);

      container = ProviderContainer(
        overrides: [
          passbookRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial build triggers loadPassbook and transitions to loaded state', () async {
      final PassbookController controller =
          container.read(passbookControllerProvider.notifier);
      await controller.loadPassbook();

      final PassbookState state = container.read(passbookControllerProvider);
      expect(state.isLoaded, isTrue);
      expect(state.entries.length, 12);
      expect(state.summary, isNotNull);
      expect(state.summary!.chitToken, '#SW-042');
      expect(state.summary!.totalMonths, 12);
      expect(state.summary!.monthsPaid, 8);
      expect(state.summary!.totalPaid, 40000);
      expect(state.viewMode, PassbookViewMode.table);
    });

    test('setViewMode toggles between table and card view cleanly', () async {
      final PassbookController controller =
          container.read(passbookControllerProvider.notifier);
      await controller.loadPassbook();

      expect(container.read(passbookControllerProvider).isTableView, isTrue);

      controller.setViewMode(PassbookViewMode.card);
      expect(container.read(passbookControllerProvider).isCardView, isTrue);

      controller.setViewMode(PassbookViewMode.table);
      expect(container.read(passbookControllerProvider).isTableView, isTrue);
    });

    test('loadPassbook with refresh preserves current data during reload', () async {
      final PassbookController controller =
          container.read(passbookControllerProvider.notifier);
      await controller.loadPassbook();

      await controller.loadPassbook(refresh: true);
      final PassbookState refreshedState = container.read(passbookControllerProvider);
      expect(refreshedState.isLoaded, isTrue);
      expect(refreshedState.entries.length, 12);
    });

    test('Transitions to empty state when no active scheme is present', () async {
      mockRepository.setHasActiveScheme(false);
      final PassbookController controller =
          container.read(passbookControllerProvider.notifier);
      await controller.loadPassbook();

      final PassbookState state = container.read(passbookControllerProvider);
      expect(state.isEmpty, isTrue);
      expect(state.entries, isEmpty);
      expect(state.summary, isNull);
    });

    test('Transitions to error state on failure and recovers on retry', () async {
      mockRepository.setShouldThrow(true);
      final PassbookController controller =
          container.read(passbookControllerProvider.notifier);
      await controller.loadPassbook();

      final PassbookState errorState = container.read(passbookControllerProvider);
      expect(errorState.isError, isTrue);
      expect(errorState.errorMessage, isNotNull);

      // Now fix and retry
      mockRepository.setShouldThrow(false);
      await controller.retry();

      final PassbookState recoveredState = container.read(passbookControllerProvider);
      expect(recoveredState.isLoaded, isTrue);
      expect(recoveredState.entries.length, 12);
    });
  });
}
