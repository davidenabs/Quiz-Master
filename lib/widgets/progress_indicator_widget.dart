import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int current;
  final int total;
  const ProgressIndicatorWidget({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final percent = current / total;
    return SizedBox(
      width: 120,
      child: LinearProgressIndicator(
        value: percent,
        backgroundColor: Colors.white24,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        minHeight: 8,
      ),
    );
  }
}