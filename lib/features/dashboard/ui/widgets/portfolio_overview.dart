// lib/features/dashboard/ui/widgets/portfolio_overview.dart

import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/core/models/portfolio.dart';

class PortfolioOverview extends StatelessWidget {
  final Portfolio portfolio;

  const PortfolioOverview({super.key, required this.portfolio});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portfolio Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text('Total Value: \$${portfolio.totalValue.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            ...portfolio.assets.entries
                .map((entry) =>
                    Text('${entry.key}: ${entry.value.toStringAsFixed(8)}'))
                ,
          ],
        ),
      ),
    );
  }
}
