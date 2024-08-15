import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/core/widgets/custom_card.dart';

class TradeStats extends StatelessWidget {
  final Map<String, dynamic> stats;

  const TradeStats({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      title: 'Trade Statistics',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatRow(
              'Total Trades', stats['totalTrades']?.toString() ?? 'N/A'),
          _buildStatRow(
              'Profit Trades', stats['profitableTrades']?.toString() ?? 'N/A'),
          _buildStatRow(
              'Loss Trades',
              ((stats['totalTrades'] ?? 0) - (stats['profitableTrades'] ?? 0))
                  .toString()),
          _buildStatRow('Total Profit',
              '\$${(stats['totalProfit'] ?? 0).toStringAsFixed(2)}'),
          _buildStatRow('Win Rate',
              '${((stats['winRate'] ?? 0) * 100).toStringAsFixed(2)}%'),
          _buildStatRow('Average Profit',
              '\$${(stats['averageProfit'] ?? 0).toStringAsFixed(2)}'),
          _buildStatRow('Average Loss',
              '\$${(stats['averageLoss'] ?? 0).toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          Text('Asset Volumes:',
              style: Theme.of(context).textTheme.titleMedium),
          ..._buildAssetVolumes(),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  List<Widget> _buildAssetVolumes() {
    final assetVolumes = stats['assetVolumes'] as Map<dynamic, dynamic>? ?? {};
    return assetVolumes.entries
        .map(
          (entry) => _buildStatRow(entry.key.toString(),
              '\$${(entry.value as num).toStringAsFixed(2)}'),
        )
        .toList();
  }
}
