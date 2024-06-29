// lib/features/strategy/ui/widgets/strategy_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StrategyChart extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;

  const StrategyChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return const Center(child: Text('No chart data available'));
    }
    final minY = chartData
        .map((d) => (d['value'] as num).toDouble())
        .reduce((a, b) => a < b ? a : b);
    final maxY = chartData
        .map((d) => (d['value'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: true),
              minX: 0,
              maxX: chartData.length.toDouble() - 1,
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: chartData.asMap().entries.map((entry) {
                    return FlSpot(
                      entry.key.toDouble(),
                      (entry.value['value'] as num).toDouble(),
                    );
                  }).toList(),
                  isCurved: true,
                  color: Theme.of(context).primaryColor,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context).primaryColor.withOpacity(0.3)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
