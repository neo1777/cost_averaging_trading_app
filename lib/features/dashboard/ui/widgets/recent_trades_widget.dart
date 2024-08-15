import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/core/models/trade.dart';
import 'package:cost_averaging_trading_app/core/widgets/custom_card.dart';
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
    return CustomCard(
      title: 'Recent Trades',
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: trades.length > 5 ? 5 : trades.length,
            itemBuilder: (context, index) {
              final trade = trades[index];
              return ListTile(
                leading: Icon(
                  trade.type == CoreTradeType.buy ? Icons.arrow_downward : Icons.arrow_upward,
                  color: trade.type == CoreTradeType.buy ? Colors.green : Colors.red,
                ),
                title: Text('${trade.type.name.toUpperCase()} ${trade.amount} ${trade.symbol}'),
                subtitle: Text('Price: ${trade.price} | ${DateFormat.yMd().add_Hms().format(trade.timestamp)}'),
                trailing: Text(
                  '${trade.type == CoreTradeType.buy ? '-' : '+'}${(trade.amount * trade.price).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: trade.type == CoreTradeType.buy ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onViewAllTrades,
            child: const Text('View All Trades'),
          ),
        ],
      ),
    );
  }
}