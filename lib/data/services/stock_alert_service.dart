import 'package:dio/dio.dart';

import '../../domain/models/product.dart';

class StockAlertService {
  StockAlertService(this._dio);

  static const _webhookUrl = String.fromEnvironment('ALERT_WEBHOOK_URL');

  final Dio _dio;

  Future<String> notifyLowStock(List<Product> products) async {
    if (_webhookUrl.isEmpty) {
      return 'Webhook non configure. Ajoutez ALERT_WEBHOOK_URL pour activer l\'envoi externe.';
    }

    final payload = {
      'generatedAt': DateTime.now().toIso8601String(),
      'criticalProducts': products
          .map(
            (product) => {
              'name': product.name,
              'stockQuantity': product.stockQuantity,
              'reorderThreshold': product.reorderThreshold,
            },
          )
          .toList(),
    };

    await _dio.post(_webhookUrl, data: payload);
    return 'Notification externe envoyee avec succes.';
  }
}
