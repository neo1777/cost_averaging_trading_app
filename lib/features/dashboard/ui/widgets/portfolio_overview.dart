import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/core/models/portfolio.dart';

class PortfolioOverview extends StatelessWidget {
  final Portfolio portfolio;

  const PortfolioOverview({super.key, required this.portfolio});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Portfolio Overview',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Text(
          'Total Value: \$${portfolio.totalValue.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...portfolio.assets.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('${entry.key}: ${entry.value.toStringAsFixed(8)}'),
            )),
      ],
    );
  }
}
