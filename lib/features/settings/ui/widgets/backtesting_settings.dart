import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/core/widgets/custom_card.dart';
import 'package:cost_averaging_trading_app/core/widgets/custom_button.dart';

class BacktestingSettings extends StatelessWidget {
  final bool isBacktestingEnabled;
  final VoidCallback onToggleBacktesting;
  final VoidCallback onRunBacktest;

  const BacktestingSettings({
    super.key,
    required this.isBacktestingEnabled,
    required this.onToggleBacktesting,
    required this.onRunBacktest,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      title: 'Backtesting',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text('Enable Backtesting'),
            value: isBacktestingEnabled,
            onChanged: (value) => onToggleBacktesting(),
          ),
          const SizedBox(height: 16),
          CustomButton(
            label: 'Run Backtest',
            onPressed: isBacktestingEnabled ? onRunBacktest : null,
            icon: Icons.play_arrow,
          ),
        ],
      ),
    );
  }
}