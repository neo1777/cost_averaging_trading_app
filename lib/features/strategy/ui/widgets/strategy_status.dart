// lib/features/strategy/ui/widgets/strategy_status.dart

import 'package:flutter/material.dart';

enum StrategyStatus { inactive, active, paused }

class StrategyStatusWidget extends StatelessWidget {
  final StrategyStatus status;

  const StrategyStatusWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Strategy Status:'),
            _buildStatusChip(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    String label;

    switch (status) {
      case StrategyStatus.inactive:
        color = Colors.grey;
        label = 'Inactive';
        break;
      case StrategyStatus.active:
        color = Colors.green;
        label = 'Active';
        break;
      case StrategyStatus.paused:
        color = Colors.orange;
        label = 'Paused';
        break;
    }

    return Chip(
      label: Text(label),
      backgroundColor: color,
    );
  }
}