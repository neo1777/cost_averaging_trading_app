import 'package:cost_averaging_trading_app/core/models/trade.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TradeList extends StatelessWidget {
  final List<CoreTrade> trades;

  const TradeList({super.key, required this.trades});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trades.length,
      itemBuilder: (context, index) {
        final trade = trades[index];
        return Card(
          child: ListTile(
            title: Text('${trade.type.name.toUpperCase()} ${trade.amount} ${trade.symbol}'),
            subtitle: Text('Price: ${trade.price} | ${DateFormat.yMd().add_Hms().format(trade.timestamp)}'),
            trailing: Text(
              '${trade.type.name == 'buy' ? '-' : '+'}${(trade.amount * trade.price).toStringAsFixed(2)}',
              style: TextStyle(
                color: trade.type.name == 'buy' ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}