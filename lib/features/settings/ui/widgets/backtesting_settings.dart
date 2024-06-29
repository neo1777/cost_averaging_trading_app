import 'package:flutter/material.dart';

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Backtesting', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Enable Backtesting',
                    style: Theme.of(context).textTheme.titleMedium),
                Switch(
                  value: isBacktestingEnabled,
                  onChanged: (_) => onToggleBacktesting(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isBacktestingEnabled ? onRunBacktest : null,
              child: const Text('Run Backtest'),
            ),
          ],
        ),
      ),
    );
  }
}
