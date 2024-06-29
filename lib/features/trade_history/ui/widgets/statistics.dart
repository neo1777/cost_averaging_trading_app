import 'package:flutter/material.dart';

class Statistics extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const Statistics({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trade Statistics', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('Total Trades: ${statistics['totalTrades']}'),
            Text('Buy Trades: ${statistics['buyTrades']}'),
            Text('Sell Trades: ${statistics['sellTrades']}'),
            Text('Total Volume: \$${statistics['totalVolume'].toStringAsFixed(2)}'),
            Text('Total Profit/Loss: \$${statistics['totalProfit'].toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Asset Volumes:', style: Theme.of(context).textTheme.titleMedium),
            ...(statistics['assetVolumes'] as Map<String, double>).entries.map(
              (entry) => Text('${entry.key}: \$${entry.value.toStringAsFixed(2)}'),
            ),
          ],
        ),
      ),
    );
  }
}