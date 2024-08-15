import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/core/widgets/custom_card.dart';

class PortfolioSummary extends StatelessWidget {
  final double totalValue;
  final double dailyChange;
  final double weeklyChange;

  const PortfolioSummary({
    super.key,
    required this.totalValue,
    required this.dailyChange,
    required this.weeklyChange,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      title: 'Portfolio Summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Value: \$${totalValue.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          _buildChangeRow('24h Change', dailyChange),
          _buildChangeRow('7d Change', weeklyChange),
        ],
      ),
    );
  }

  Widget _buildChangeRow(String label, double change) {
    final isPositive = change >= 0;
    final changeText = '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%';
    final changeColor = isPositive ? Colors.green : Colors.red;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          changeText,
          style: TextStyle(
            color: changeColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}