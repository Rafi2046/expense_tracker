import 'package:flutter/material.dart';

class SelectDateInputDialogResult {
  final DateTimeRange range;
  final bool shouldSubmit;

  SelectDateInputDialogResult({
    required this.range,
    required this.shouldSubmit,
  });
}
