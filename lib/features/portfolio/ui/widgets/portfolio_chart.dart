import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cost_averaging_trading_app/core/widgets/custom_card.dart';

class PortfolioChart extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;

  const PortfolioChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      title: 'Portfolio Performance',
      child: SizedBox(
        height: 300,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: true),
            minX: 0,
            maxX: chartData.length.toDouble() - 1,
            minY: chartData.map((d) => d['value'] as double).reduce((a, b) => a < b ? a : b),
            maxY: chartData.map((d) => d['value'] as double).reduce((a, b) => a > b ? a : b),
            lineBarsData: [
              LineChartBarData(
                spots: chartData.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value['value'] as double);
                }).toList(),
                isCurved: true,
                color: Theme.of(context).primaryColor,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: true, color: Theme.of(context).primaryColor.withOpacity(0.3)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}