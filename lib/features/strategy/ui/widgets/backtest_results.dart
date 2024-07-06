import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cost_averaging_trading_app/core/services/backtesting_service.dart';
import 'package:cost_averaging_trading_app/core/models/trade.dart';

class BacktestResults extends StatelessWidget {
  final BacktestResult? backtestResult;
  final Function(DateTime startDate, DateTime endDate) onRunBacktest;

  const BacktestResults({
    super.key,
    this.backtestResult,
    required this.onRunBacktest,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Backtest Results',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildBacktestControls(context),
        if (backtestResult != null) ...[
          const SizedBox(height: 16),
          _buildPerformanceSummary(context),
          const SizedBox(height: 16),
          _buildPerformanceChart(context),
          const SizedBox(height: 16),
          _buildTradesList(context),
        ],
      ],
    );
  }

  Widget _buildBacktestControls(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            final now = DateTime.now();
            final oneYearAgo = now.subtract(const Duration(days: 365));
            onRunBacktest(oneYearAgo, now);
          },
          child: const Text('Run Backtest (Last Year)'),
        ),
      ],
    );
  }

  Widget _buildPerformanceSummary(BuildContext context) {
    final performance = backtestResult!.performance;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Performance Summary',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
                'Total Profit: \$${performance.totalProfit.toStringAsFixed(2)}'),
            Text(
                'Total Return: ${(performance.totalReturn * 100).toStringAsFixed(2)}%'),
            Text(
                'Max Drawdown: ${(performance.maxDrawdown * 100).toStringAsFixed(2)}%'),
            Text(
                'Win Rate: ${(performance.winRate * 100).toStringAsFixed(2)}%'),
            Text('Sharpe Ratio: ${performance.sharpeRatio.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart(BuildContext context) {
    // Create data points for the chart
    final trades = backtestResult!.trades;
    final dataPoints = trades.map((trade) {
      return FlSpot(
        trade.timestamp.millisecondsSinceEpoch.toDouble(),
        trade.price,
      );
    }).toList();

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: true),
          minX: dataPoints.first.x,
          maxX: dataPoints.last.x,
          minY: dataPoints.map((e) => e.y).reduce((a, b) => a < b ? a : b),
          maxY: dataPoints.map((e) => e.y).reduce((a, b) => a > b ? a : b),
          lineBarsData: [
            LineChartBarData(
              spots: dataPoints,
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradesList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trades',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            itemCount: backtestResult!.trades.length,
            itemBuilder: (context, index) {
              final trade = backtestResult!.trades[index];
              return ListTile(
                title: Text(
                    '${trade.type == CoreTradeType.buy ? 'Buy' : 'Sell'} ${trade.amount.toStringAsFixed(8)} ${trade.symbol}'),
                subtitle: Text('Price: \$${trade.price.toStringAsFixed(2)}'),
                trailing: Text(trade.timestamp.toString().split(' ')[0]),
              );
            },
          ),
        ),
      ],
    );
  }
}
