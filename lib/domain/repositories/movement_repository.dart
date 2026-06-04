import '../models/stock_movement.dart';

abstract class MovementRepository {
  Stream<List<StockMovement>> watchMovements(String clientId);
  Future<void> addMovement({
    required String clientId,
    required StockMovement movement,
  });
  Future<List<StockMovement>> getMovementsByDateRange({
    required String clientId,
    required DateTime start,
    required DateTime end,
  });
}
