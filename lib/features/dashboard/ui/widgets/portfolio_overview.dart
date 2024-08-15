import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/core/widgets/custom_card.dart';

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
    return CustomCard(
      title: 'Portfolio Overview',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Value: \$${totalValue.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '24h Change: ${_formatChange(dailyChange)}',
            style: TextStyle(
              color: dailyChange >= 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text('Asset Distribution:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...assets.entries.map((entry) => _buildAssetRow(entry.key, entry.value)),
        ],
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