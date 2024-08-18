import 'package:cost_averaging_trading_app/candlestick/candlesticks.dart';
import 'package:cost_averaging_trading_app/candlestick/models/candle.dart';
import 'package:flutter/material.dart';

class MarketChart extends StatelessWidget {
  final List<Candle> candles;
  final String symbol;
  final Function(String) onSymbolChanged;

  const MarketChart({
    Key? key,
    required this.candles,
    required this.symbol,
    required this.onSymbolChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<String>(
          value: symbol,
          items: ['ETHBTC', 'BTCUSDT', 'ETHUSDT'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onSymbolChanged(newValue);
            }
          },
        ),
        Expanded(
          child: Candlesticks(
            candles: candles,
          ),
        ),
      ],
    );
  }
}