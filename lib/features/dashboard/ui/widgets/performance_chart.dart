import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cost_averaging_trading_app/core/widgets/custom_card.dart';

class PerformanceChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const PerformanceChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const CustomCard(
        title: 'Performance Chart',
        child: Center(child: Text('No data available')),
      );
    }

    final spots = data.map((entry) {
      final x = entry['date'] is DateTime
          ? entry['date'].millisecondsSinceEpoch.toDouble()
          : 0.0;
      final y =
          entry['value'] is num ? (entry['value'] as num).toDouble() : 0.0;
      return FlSpot(x, y);
    }).toList();

    final minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

    return CustomCard(
      title: 'Performance Chart',
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: true),
            minX: spots.first.x,
            maxX: spots.last.x,
            minY: minY,
            maxY: maxY,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
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
    );
  }
}
