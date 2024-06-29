import 'package:flutter/material.dart';

class RiskInfoCard extends StatelessWidget {
  final double maxLossPercentage;
  final int maxConcurrentTrades;
  final double maxPositionSizePercentage;
  final double dailyExposureLimit;
  final double maxAllowedVolatility;
  final int maxRebuyCount;

  const RiskInfoCard({
    super.key,
    required this.maxLossPercentage,
    required this.maxConcurrentTrades,
    required this.maxPositionSizePercentage,
    required this.dailyExposureLimit,
    required this.maxAllowedVolatility,
    required this.maxRebuyCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Risk Management Settings',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildInfoRow('Max Loss Percentage',
                '${maxLossPercentage.toStringAsFixed(2)}%'),
            _buildInfoRow(
                'Max Concurrent Trades', maxConcurrentTrades.toString()),
            _buildInfoRow('Max Position Size',
                '${maxPositionSizePercentage.toStringAsFixed(2)}%'),
            _buildInfoRow('Daily Exposure Limit',
                '\$${dailyExposureLimit.toStringAsFixed(2)}'),
            _buildInfoRow('Max Allowed Volatility',
                '${(maxAllowedVolatility * 100).toStringAsFixed(2)}%'),
            _buildInfoRow('Max Rebuy Count', maxRebuyCount.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
