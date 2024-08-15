import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/core/models/trade.dart';
import 'package:cost_averaging_trading_app/core/widgets/custom_card.dart';
import 'package:fl_chart/fl_chart.dart';

class StrategyMonitor extends StatelessWidget {
  final double totalInvested;
  final double currentProfit;
  final int tradeCount;
  final double averageBuyPrice;
  final double currentMarketPrice;
  final List<CoreTrade> recentTrades;

  const StrategyMonitor({
    super.key,
    required this.totalInvested,
    required this.currentProfit,
    required this.tradeCount,
    required this.averageBuyPrice,
    required this.currentMarketPrice,
    required this.recentTrades,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      title: 'Strategy Monitor',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverview(context),
          const SizedBox(height: 16),
          _buildPriceChart(context),
          const SizedBox(height: 16),
          _buildRecentTrades(context),
        ],
      ),
    );
  }

  Widget _buildOverview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Total Invested: \$${totalInvested.toStringAsFixed(2)}'),
        Text('Current Profit/Loss: \$${currentProfit.toStringAsFixed(2)}'),
        Text('Number of Trades: $tradeCount'),
        Text('Average Buy Price: \$${averageBuyPrice.toStringAsFixed(2)}'),
        Text('Current Market Price: \$${currentMarketPrice.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildPriceChart(BuildContext context) {
    final priceData = recentTrades.map((trade) => FlSpot(
      trade.timestamp.millisecondsSinceEpoch.toDouble(),
      trade.price,
    )).toList();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: true),
          minX: priceData.first.x,
          maxX: priceData.last.x,
          minY: priceData.map((e) => e.y).reduce((a, b) => a < b ? a : b),
          maxY: priceData.map((e) => e.y).reduce((a, b) => a > b ? a : b),
          lineBarsData: [
            LineChartBarData(
              spots: priceData,
              isCurved: true,
              color: Theme.of(context).primaryColor,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTrades(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Trades',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentTrades.length > 5 ? 5 : recentTrades.length,
          itemBuilder: (context, index) {
            final trade = recentTrades[index];
            return ListTile(
              title: Text(
                '${trade.type == CoreTradeType.buy ? 'Buy' : 'Sell'} ${trade.amount.toStringAsFixed(8)} ${trade.symbol}',
              ),
              subtitle: Text('Price: \$${trade.price.toStringAsFixed(2)}'),
              trailing: Text(trade.timestamp.toString().split(' ')[0]),
            );
          },
        ),
      ],
    );
  }
}