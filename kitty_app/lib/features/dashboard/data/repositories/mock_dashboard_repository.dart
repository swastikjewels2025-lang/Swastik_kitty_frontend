import '../../../../core/enums/app_enums.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/mock/mock_engine_config.dart';
import '../../../../core/mock/mock_fixtures.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import '../../domain/repositories/i_dashboard_repository.dart';
import '../dtos/dashboard_dto.dart';
import '../mappers/dashboard_mapper.dart';

/// Mock implementation of [IDashboardRepository].
class MockDashboardRepository implements IDashboardRepository {
  MockDashboardRepository({MockEngineConfig? engineConfig})
      : _engineConfig = engineConfig ?? MockEngineConfig.instance;

  final MockEngineConfig _engineConfig;
  bool _hasActiveScheme = true;
  bool _multipleSchemes = true;
  List<DashboardSummaryEntity>? _customSchemes;
  MembershipStatusEnum _status = MembershipStatusEnum.active;
  bool _shouldThrow = false;

  /// Allows toggling empty dashboard state for testing empty states.
  void setHasActiveScheme(bool hasActive) {
    _hasActiveScheme = hasActive;
  }

  /// Sets mock status (e.g. active, preJoin, completed).
  void setStatus(MembershipStatusEnum status) {
    _status = status;
  }

  /// Forces throwing an exception for testing error handling.
  void setShouldThrow(bool shouldThrow) {
    _shouldThrow = shouldThrow;
  }

  /// Allows toggling multiple active schemes vs single active scheme.
  void setMultipleSchemes(bool enabled) {
    _multipleSchemes = enabled;
  }

  /// Explicitly overrides active schemes list for testing.
  void setSchemes(List<DashboardSummaryEntity> schemes) {
    _customSchemes = schemes;
  }

  @override
  Future<DashboardSummaryEntity> getMyDashboard() async {
    await _engineConfig.simulate();

    if (_shouldThrow) {
      throw const NetworkException('Failed to retrieve kitty dashboard summary.');
    }

    if (!_hasActiveScheme) {
      return const DashboardSummaryEntity(hasActiveScheme: false);
    }

    final DashboardSummaryResponseDto dto =
        DashboardSummaryResponseDto.fromJson(
      MockFixtures.dashboardActiveSuvarnaJson['data'] as Map<String, dynamic>,
    );

    final DashboardSummaryEntity baseEntity = DashboardMapper.toEntity(dto);
    if (_status != MembershipStatusEnum.active) {
      return DashboardSummaryEntity(
        hasActiveScheme: baseEntity.hasActiveScheme,
        membershipId: baseEntity.membershipId,
        chitToken: baseEntity.chitToken,
        schemeName: baseEntity.schemeName,
        targetAmount: baseEntity.targetAmount,
        customMonthlyEmi: baseEntity.customMonthlyEmi,
        totalMonths: baseEntity.totalMonths,
        monthsPaid: _status == MembershipStatusEnum.completed ? baseEntity.totalMonths : baseEntity.monthsPaid,
        totalPaidAmount: _status == MembershipStatusEnum.completed ? baseEntity.targetAmount : baseEntity.totalPaidAmount,
        remainingAmount: _status == MembershipStatusEnum.completed ? 0 : baseEntity.remainingAmount,
        accumulatedGoldGrams: baseEntity.accumulatedGoldGrams,
        currentValuation: baseEntity.currentValuation,
        valuationGainPct: baseEntity.valuationGainPct,
        nextInstallment: _status == MembershipStatusEnum.completed ? null : baseEntity.nextInstallment,
        passbook: baseEntity.passbook,
        status: _status,
      );
    }

    return baseEntity;
  }

  @override
  Future<List<DashboardSummaryEntity>> getMySchemes() async {
    if (_shouldThrow) {
      throw const NetworkException('Failed to retrieve kitty schemes.');
    }

    if (!_hasActiveScheme) {
      return const <DashboardSummaryEntity>[];
    }

    if (_customSchemes != null) {
      return _customSchemes!;
    }

    final DashboardSummaryEntity primary = await getMyDashboard();

    if (!_multipleSchemes) {
      return <DashboardSummaryEntity>[primary];
    }

    // Default multi-scheme portfolio:
    // Scheme 1: ₹5,000/mo (Swastik Swarna Varsha)
    // Scheme 2: ₹2,000/mo (Dhanvantari Wealth Plan)
    // Scheme 3: ₹3,000/mo (Akshaya Gold Reserve)
    final DashboardSummaryEntity scheme2 = DashboardSummaryEntity(
      hasActiveScheme: true,
      membershipId: 'mem_883322',
      chitToken: '#SW-018',
      schemeName: 'Dhanvantari Wealth Plan',
      targetAmount: 24000,
      customMonthlyEmi: 2000,
      totalMonths: 12,
      monthsPaid: 4,
      totalPaidAmount: 8000,
      remainingAmount: 14000,
      accumulatedGoldGrams: 1.085,
      currentValuation: 8120,
      valuationGainPct: 1.50,
      nextInstallment: NextInstallmentEntity(
        month: 5,
        amount: 2000,
        dueDate: DateTime.now().add(const Duration(days: 10)),
        daysRemaining: 10,
      ),
      status: MembershipStatusEnum.active,
    );

    final DashboardSummaryEntity scheme3 = DashboardSummaryEntity(
      hasActiveScheme: true,
      membershipId: 'mem_772211',
      chitToken: '#SW-031',
      schemeName: 'Akshaya Gold Reserve',
      targetAmount: 36000,
      customMonthlyEmi: 3000,
      totalMonths: 12,
      monthsPaid: 11,
      totalPaidAmount: 33000,
      remainingAmount: 0,
      accumulatedGoldGrams: 4.512,
      currentValuation: 34200,
      valuationGainPct: 3.63,
      nextInstallment: NextInstallmentEntity(
        month: 12,
        amount: 0,
        dueDate: DateTime.now().add(const Duration(days: 20)),
        daysRemaining: 20,
      ),
      status: MembershipStatusEnum.active,
    );

    return <DashboardSummaryEntity>[primary, scheme2, scheme3];
  }
}
