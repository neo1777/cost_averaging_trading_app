// lib/core/models/trade.dart

import 'package:equatable/equatable.dart';

enum CoreTradeType { buy, sell }

class CoreTrade extends Equatable {
  final String id;
  final String symbol;
  final double amount;
  final double price;
  final DateTime timestamp;
  final CoreTradeType type;

  const CoreTrade({
    required this.id,
    required this.symbol,
    required this.amount,
    required this.price,
    required this.timestamp,
    required this.type,
  });

  @override
  List<Object?> get props => [id, symbol, amount, price, timestamp, type];

  CoreTrade copyWith({
    String? id,
    String? symbol,
    double? amount,
    double? price,
    DateTime? timestamp,
    CoreTradeType? type,
  }) {
    return CoreTrade(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      amount: amount ?? this.amount,
      price: price ?? this.price,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }

factory CoreTrade.fromJson(Map<String, dynamic> json) {
    return CoreTrade(
      id: json['id']?.toString() ?? '',
      symbol: json['symbol'] ?? '',
      amount: double.tryParse(json['qty']?.toString() ?? '0') ?? 0.0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      timestamp: json['time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['time'] as int)
          : DateTime.now(),
      type: json['isBuyer'] == true ? CoreTradeType.buy : CoreTradeType.sell,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'amount': amount,
      'price': price,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type == CoreTradeType.buy ? 'buy' : 'sell',
    };
  }
}
