
import 'package:cost_averaging_trading_app/core/models/trade.dart';
import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/core/services/backtesting_service.dart';

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
          _buildBacktestSummary(context),
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
            // Implementa la logica per selezionare le date
            final now = DateTime.now();
            final oneYearAgo = now.subtract(const Duration(days: 365));
            onRunBacktest(oneYearAgo, now);
          },
          child: const Text('Run Backtest'),
        ),
      ],
    );
  }

  Widget _buildBacktestSummary(BuildContext context) {
    final performance = backtestResult!.performance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Total Profit: \$${performance.totalProfit.toStringAsFixed(2)}'),
        Text('Win Rate: ${(performance.winRate * 100).toStringAsFixed(2)}%'),
        Text('Max Drawdown: ${(performance.maxDrawdown * 100).toStringAsFixed(2)}%'),
        Text('Sharpe Ratio: ${performance.sharpeRatio.toStringAsFixed(2)}'),
      ],
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
                title: Text('${trade.type == CoreTradeType.buy ? 'Buy' : 'Sell'} ${trade.amount} ${trade.symbol}'),
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