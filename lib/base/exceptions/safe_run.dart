import 'package:flutter/material.dart';

Future safeRun(Function action) async {
  try {
    await action();
  } catch (e) {
    debugPrint('Safe Error: $e');
  }
}