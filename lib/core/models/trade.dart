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
      id: json['id'],
      symbol: json['symbol'],
      amount: json['amount'],
      price: json['price'],
      timestamp: DateTime.parse(json['timestamp']),
      type: CoreTradeType.values
          .firstWhere((e) => e.toString() == 'CoreTradeType.${json['type']}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'amount': amount,
      'price': price,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
    };
  }
}
