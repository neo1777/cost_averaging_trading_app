import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BacktestProgressChart extends StatelessWidget {
  final List<FlSpot> spots;
  final double minY;
  final double maxY;

  const BacktestProgressChart({
    super.key,
    required this.spots,
    required this.minY,
    required this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.70,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: true),
          minX: 0,
          maxX: spots.length.toDouble() - 1,
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Theme.of(context).primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
