import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stock_flutter/presentation/widgets/metric_card.dart';

void main() {
  testWidgets('MetricCard displays its label and value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MetricCard(
            label: 'Produits critiques',
            value: '3',
            icon: Icons.warning_amber,
          ),
        ),
      ),
    );

    expect(find.text('Produits critiques'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });
}
