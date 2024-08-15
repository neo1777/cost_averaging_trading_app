import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/core/widgets/custom_card.dart';
import 'package:cost_averaging_trading_app/core/widgets/custom_button.dart';

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
    return CustomCard(
      title: 'Strategy Status',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              CustomButton(
                label: 'Start Strategy',
                onPressed: status == StrategyStatus.inactive ? onStart : null,
                icon: Icons.play_arrow,
              ),
              CustomButton(
                label: 'Stop Strategy',
                onPressed: status == StrategyStatus.active ? onStop : null,
                icon: Icons.stop,
                color: Colors.red,
              ),
              CustomButton(
                label: 'Sell Entire Portfolio',
                onPressed: status == StrategyStatus.active ? onSellEntirePortfolio : null,
                icon: Icons.sell,
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
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