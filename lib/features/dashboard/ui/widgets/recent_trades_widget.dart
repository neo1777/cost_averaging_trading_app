// lib/features/dashboard/ui/widgets/recent_trades_widget.dart

import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/core/models/trade.dart';
import 'package:intl/intl.dart';

class RecentTradesWidget extends StatelessWidget {
  final List<CoreTrade> trades;
  final VoidCallback onViewAllTrades;

  const RecentTradesWidget({
    super.key,
    required this.trades,
    required this.onViewAllTrades,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Trades',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: trades.isEmpty
                  ? const Center(child: Text('No recent trades'))
                  : ListView.builder(
                      itemCount: trades.length,
                      itemBuilder: (context, index) {
                        final trade = trades[index];
                        return ListTile(
                          leading: Icon(
                            trade.type == CoreTradeType.buy
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: trade.type == CoreTradeType.buy
                                ? Colors.green
                                : Colors.red,
                          ),
                          title: Text(
                            '${trade.type.name.toUpperCase()} ${trade.amount.toStringAsFixed(5)} ${trade.symbol}',
                          ),
                          subtitle: Text(
                            'Price: ${trade.price.toStringAsFixed(2)} | ${DateFormat.yMd().add_Hms().format(trade.timestamp)}',
                          ),
                          trailing: Text(
                            '${trade.type == CoreTradeType.buy ? '-' : '+'}${(trade.amount * trade.price).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: trade.type == CoreTradeType.buy
                                  ? Colors.red
                                  : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onViewAllTrades,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('View All Trades'),
            ),
          ],
        ),
      ),
    );
  }
}
