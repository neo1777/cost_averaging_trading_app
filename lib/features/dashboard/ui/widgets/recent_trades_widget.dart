import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/core/models/trade.dart';
import 'package:cost_averaging_trading_app/core/widgets/custom_card.dart';
import 'package:intl/intl.dart';

class RecentTradesWidget extends StatelessWidget {
  final List<CoreTrade> trades;
  final VoidCallback onViewAllTrades;

  const RecentTradesWidget({
    Key? key,
    required this.trades,
    required this.onViewAllTrades,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.builder(
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
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Price: ${trade.price.toStringAsFixed(2)} | ${DateFormat.yMd().add_Hms().format(trade.timestamp)}',
                  style: TextStyle(color: Colors.grey),
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
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: onViewAllTrades,
          child: Text('View All Trades'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
        ),
      ],
    );
  }
}
