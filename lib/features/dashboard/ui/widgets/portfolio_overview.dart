// lib/features/dashboard/ui/widgets/portfolio_overview.dart

import 'package:flutter/material.dart';

class PortfolioOverview extends StatelessWidget {
  final double totalValue;
  final double dailyChange;
  final Map<String, double> assets;

  const PortfolioOverview({
    super.key,
    required this.totalValue,
    required this.dailyChange,
    required this.assets,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portfolio Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Total Value: \$${totalValue.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              '24h Change: ${_formatChange(dailyChange)}',
              style: TextStyle(
                color: dailyChange >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text('Asset Distribution:',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: assets.entries
                    .map((entry) => _buildAssetRow(entry.key, entry.value))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetRow(String asset, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(asset),
          Text(amount.toStringAsFixed(8)),
        ],
      ),
    );
  }

  String _formatChange(double change) {
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(2)}%';
  }
}
