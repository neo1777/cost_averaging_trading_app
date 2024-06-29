import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cost_averaging_trading_app/core/models/trade.dart';

class RecentTradesWidget extends StatelessWidget {
  final List<CoreTrade> trades;
  final int currentPage;
  final int tradesPerPage;
  final Function() onLoadMore;
  final Function(int) onChangeTradesPerPage;

  const RecentTradesWidget({
    super.key,
    required this.trades,
    required this.currentPage,
    required this.tradesPerPage,
    required this.onLoadMore,
    required this.onChangeTradesPerPage,
  });

  @override
  Widget build(BuildContext context) {
    final displayedTrades = trades.take(tradesPerPage).toList();

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
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedTrades.length,
              itemBuilder: (context, index) {
                final trade = displayedTrades[index];
                return _buildTradeItem(trade);
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: onLoadMore,
                  child: const Text('Load More'),
                ),
                DropdownButton<int>(
                  value: tradesPerPage,
                  items: [10, 20, 50].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value per page'),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      onChangeTradesPerPage(newValue);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeItem(CoreTrade trade) {
    return ListTile(
      title: Text(
        '${trade.type == CoreTradeType.buy ? 'Buy' : 'Sell'} ${trade.symbol}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: trade.type == CoreTradeType.buy ? Colors.green : Colors.red,
        ),
      ),
      subtitle: Text(
        'Amount: ${trade.amount.toStringAsFixed(8)} | Price: \$${trade.price.toStringAsFixed(2)}',
      ),
      trailing: Text(DateFormat('yyyy-MM-dd HH:mm').format(trade.timestamp)),
    );
  }
}
