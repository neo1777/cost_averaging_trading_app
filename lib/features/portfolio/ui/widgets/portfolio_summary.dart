// lib/features/portfolio/ui/widgets/portfolio_summary.dart

import 'package:flutter/material.dart';

class PortfolioSummary extends StatelessWidget {
  final double totalValue;

  const PortfolioSummary({super.key, required this.totalValue});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portfolio Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Total Value: \$${totalValue.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
