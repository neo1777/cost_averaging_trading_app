// lib/features/portfolio/ui/widgets/portfolio_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PortfolioChart extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;

  const PortfolioChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portfolio Performance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(
                              entry.key.toDouble(), entry.value['value']))
                          .toList(),
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                          show: true,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.3)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
