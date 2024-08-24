// lib/features/strategy/ui/widgets/strategy_status.dart

import 'package:flutter/material.dart';

enum StrategyStatus { inactive, active, paused }

class StrategyStatusWidget extends StatelessWidget {
  final StrategyStatus status;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onSellEntirePortfolio;

  const StrategyStatusWidget({
    super.key,
    required this.status,
    required this.onStart,
    required this.onStop,
    required this.onSellEntirePortfolio,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Strategy Status',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Current Status: ${status.toString().split('.').last}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(status),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _buildButton(
                    context,
                    'Start Strategy',
                    status == StrategyStatus.inactive ? onStart : null,
                    Colors.green),
                _buildButton(
                    context,
                    'Stop Strategy',
                    status == StrategyStatus.active ? onStop : null,
                    Colors.red),
                _buildButton(
                    context,
                    'Sell Entire Portfolio',
                    status == StrategyStatus.active
                        ? onSellEntirePortfolio
                        : null,
                    Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label,
      VoidCallback? onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: color),
      child: Text(label),
    );
  }

  Color _getStatusColor(StrategyStatus status) {
    switch (status) {
      case StrategyStatus.active:
        return Colors.green;
      case StrategyStatus.inactive:
        return Colors.red;
      case StrategyStatus.paused:
        return Colors.orange;
    }
  }
}
