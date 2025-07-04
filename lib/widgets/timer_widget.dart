import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final int timeRemaining;
  final int totalTime;
  const TimerWidget({
    super.key,
    required this.timeRemaining,
    required this.totalTime,
  });

  @override
  Widget build(BuildContext context) {
    final percent = timeRemaining / totalTime;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: CircularProgressIndicator(
            value: percent,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 5,
          ),
        ),
        Text(
          '$timeRemaining',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
