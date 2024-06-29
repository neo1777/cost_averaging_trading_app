import 'package:equatable/equatable.dart';

enum TradeType { buy, sell }

class TradeEntity extends Equatable {
  final String id;
  final String symbol;
  final double amount;
  final double price;
  final DateTime timestamp;
  final TradeType type;

  const TradeEntity({
    required this.id,
    required this.symbol,
    required this.amount,
    required this.price,
    required this.timestamp,
    required this.type,
  });

  @override
  List<Object?> get props => [id, symbol, amount, price, timestamp, type];
}