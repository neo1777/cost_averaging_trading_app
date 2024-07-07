import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_bloc.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_event.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/core/services/backtesting_service.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/widgets/backtest_progress_chart.dart';
import 'package:provider/provider.dart';

class BacktestResultView extends StatelessWidget {
  final BacktestResult result;

  const BacktestResultView({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spots = result.investmentOverTime
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value['value']))
        .toList();

    final minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Backtest Results',
                style: Theme.of(context).textTheme.headline5),
            SizedBox(height: 16),
            BacktestProgressChart(spots: spots, minY: minY, maxY: maxY),
            SizedBox(height: 16),
            Text('Performance Metrics:',
                style: Theme.of(context).textTheme.headline6),
            Text(
                'Total Profit: \$${result.performance.totalProfit.toStringAsFixed(2)}'),
            Text(
                'Total Return: ${(result.performance.totalReturn * 100).toStringAsFixed(2)}%'),
            Text(
                'Max Drawdown: ${(result.performance.maxDrawdown * 100).toStringAsFixed(2)}%'),
            Text(
                'Win Rate: ${(result.performance.winRate * 100).toStringAsFixed(2)}%'),
            Text(
                'Sharpe Ratio: ${result.performance.sharpeRatio.toStringAsFixed(2)}'),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Back to Strategy'),
              onPressed: () =>
                  context.read<StrategyBloc>().add(LoadStrategyData()),
            ),
          ],
        ),
      ),
    );
  }
}
