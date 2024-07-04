// lib/features/strategy/ui/widgets/strategy_status.dart

import 'package:flutter/material.dart';

enum StrategyStatus { inactive, active, paused }

class StrategyStatusWidget extends StatelessWidget {
  final StrategyStatus status;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const StrategyStatusWidget({
    super.key,
    required this.status,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Strategy Status: ${status.toString().split('.').last}'),
        ElevatedButton(
          onPressed: status == StrategyStatus.inactive ? onStart : null,
          child: const Text('Start Strategy'),
        ),
        ElevatedButton(
          onPressed: status == StrategyStatus.active ? onStop : null,
          child: const Text('Stop Strategy'),
        ),
      ],
    );
  }
}
