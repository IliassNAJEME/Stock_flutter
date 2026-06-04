import '../models/dashboard_summary.dart';

abstract class DashboardRepository {
  Future<DashboardSummary> getSummary({
    required String clientId,
    required DateTime start,
    required DateTime end,
  });
}
