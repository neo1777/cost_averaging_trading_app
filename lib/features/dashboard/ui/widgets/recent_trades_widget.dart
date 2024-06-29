import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:cost_averaging_trading_app/core/models/trade.dart';

class RecentTradesWidget extends StatelessWidget {
  final List<CoreTrade> trades;

  const RecentTradesWidget({super.key, required this.trades});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Trades',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...trades.map((trade) => _buildTradeItem(trade)),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeItem(CoreTrade trade) {
    return ListTile(
      title: Text(
          '${trade.type == CoreTradeType.buy ? 'Buy' : 'Sell'} ${trade.symbol}'),
      subtitle: Text(
          'Amount: ${trade.amount.toStringAsFixed(8)} | Price: \$${trade.price.toStringAsFixed(2)}'),
      trailing: Text(DateFormat('yyyy-MM-dd HH:mm').format(trade.timestamp)),
    );
  }
}
