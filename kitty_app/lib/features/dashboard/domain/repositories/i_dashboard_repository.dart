import '../entities/dashboard_summary_entity.dart';

/// Pure domain repository interface for active customer dashboard metrics.
abstract interface class IDashboardRepository {
  /// Retrieves aggregated dashboard summary (scheme progress, next EMI, passbook).
  Future<DashboardSummaryEntity> getMyDashboard();

  /// Retrieves all active kitty schemes for multi-scheme patrons.
  Future<List<DashboardSummaryEntity>> getMySchemes();
}
