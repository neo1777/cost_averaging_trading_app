import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cost_averaging_trading_app/core/models/trade.dart';

class RecentTradesWidget extends StatelessWidget {
  final List<CoreTrade> trades;
  final int currentPage;
  final int tradesPerPage;
  final Function(int) onPageChanged;
  final Function(int) onChangeTradesPerPage;

  const RecentTradesWidget({
    super.key,
    required this.trades,
    required this.currentPage,
    required this.tradesPerPage,
    required this.onPageChanged,
    required this.onChangeTradesPerPage,
  });

  @override
  Widget build(BuildContext context) {
    final displayedTrades = trades
        .skip((currentPage - 1) * tradesPerPage)
        .take(tradesPerPage)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Trades',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (displayedTrades.isEmpty)
          const Text('No recent trades')
        else
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
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: currentPage > 1
                      ? () => onPageChanged(currentPage - 1)
                      : null,
                ),
                Text('$currentPage'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: currentPage * tradesPerPage < trades.length
                      ? () => onPageChanged(currentPage + 1)
                      : null,
                ),
              ],
            ),
            DropdownButton<int>(
              value: tradesPerPage,
              items: [5, 10, 20].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  onChangeTradesPerPage(newValue);
                }
              },
              isDense: true,
              underline: Container(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTradeItem(CoreTrade trade) {
    return ListTile(
      title: Text(
        '${trade.type.name.toUpperCase()} ${trade.symbol}',
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
