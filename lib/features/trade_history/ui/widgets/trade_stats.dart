// lib/features/trade_history/ui/widgets/trade_stats.dart

import 'package:flutter/material.dart';

class TradeStats extends StatelessWidget {
  final Map<String, dynamic> stats;

  const TradeStats({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trade Statistics',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('Total Trades: ${stats['totalTrades']}'),
            Text('Buy Trades: ${stats['buyTrades']}'),
            Text('Sell Trades: ${stats['sellTrades']}'),
            Text('Total Volume: \$${stats['totalVolume'].toStringAsFixed(2)}'),
            Text(
                'Total Profit/Loss: \$${stats['totalProfit'].toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Asset Volumes:',
                style: Theme.of(context).textTheme.titleMedium),
            ...(stats['assetVolumes'] as Map<String, double>).entries.map(
                  (entry) =>
                      Text('${entry.key}: \$${entry.value.toStringAsFixed(2)}'),
                ),
          ],
        ),
      ),
    );
  }
}
