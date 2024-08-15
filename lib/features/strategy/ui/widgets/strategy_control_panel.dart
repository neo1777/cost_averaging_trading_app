import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/core/widgets/custom_card.dart';
import 'package:cost_averaging_trading_app/core/widgets/custom_button.dart';

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
    return CustomCard(
      title: 'Strategy Control',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              CustomButton(
                label: 'Start Live',
                onPressed: isRunning ? null : onStartLive,
                icon: Icons.play_arrow,
              ),
              CustomButton(
                label: 'Start Demo',
                onPressed: isRunning ? null : onStartDemo,
                icon: Icons.movie,
              ),
              CustomButton(
                label: 'Stop',
                onPressed: isRunning ? onStop : null,
                icon: Icons.stop,
                color: Colors.red,
              ),
              CustomButton(
                label: 'Run Backtest',
                onPressed: isRunning ? null : onBacktest,
                icon: Icons.history,
                color: Colors.orange,
              ),
            ],
          ),
          if (isRunning)
            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Text(
                'Strategy is currently running',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}