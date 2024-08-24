// lib/features/strategy/ui/widgets/strategy_control_panel.dart

import 'package:flutter/material.dart';

class StrategyControlPanel extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onStartLive;
  final VoidCallback onStartDemo;
  final VoidCallback onStop;
  final VoidCallback onBacktest;

  const StrategyControlPanel({
    super.key,
    required this.isRunning,
    required this.onStartLive,
    required this.onStartDemo,
    required this.onStop,
    required this.onBacktest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Strategy Control', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                ElevatedButton(
                  onPressed: isRunning ? null : onStartLive,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text('Start Live'),
                ),
                ElevatedButton(
                  onPressed: isRunning ? null : onStartDemo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: const Text('Start Demo'),
                ),
                ElevatedButton(
                  onPressed: isRunning ? onStop : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Stop'),
                ),
                ElevatedButton(
                  onPressed: isRunning ? null : onBacktest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                  ),
                  child: const Text('Run Backtest'),
                ),
              ],
            ),
            if (isRunning)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'Strategy is currently running',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}