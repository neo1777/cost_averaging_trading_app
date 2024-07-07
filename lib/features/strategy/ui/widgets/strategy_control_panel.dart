import 'package:flutter/material.dart';

class StrategyControlPanel extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onStartLive;
  final VoidCallback onStartDemo;
  final VoidCallback onStop;
  final VoidCallback onBacktest; // Nuovo callback per il backtest

  const StrategyControlPanel({
    super.key,
    required this.isRunning,
    required this.onStartLive,
    required this.onStartDemo,
    required this.onStop,
    required this.onBacktest, // Aggiunto il nuovo parametro
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Strategy Control',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: isRunning ? null : onStartLive,
                  child: const Text('Start Live'),
                ),
                ElevatedButton(
                  onPressed: isRunning ? null : onStartDemo,
                  child: const Text('Start Demo'),
                ),
                ElevatedButton(
                  onPressed: isRunning ? onStop : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Stop'),
                ),
                ElevatedButton(
                  onPressed: isRunning
                      ? null
                      : onBacktest,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), // Nuovo pulsante per il backtest
                  child: const Text('Run Backtest'),
                ),
              ],
            ),
            if (isRunning)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  'Strategy is currently running',
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
