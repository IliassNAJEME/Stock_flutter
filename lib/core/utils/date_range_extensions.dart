import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateRangeFormatting on DateTimeRange {
  String toDisplayLabel() {
    final formatter = DateFormat('dd/MM/yyyy');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }
}
