import 'package:cost_averaging_trading_app/core/models/trade.dart';

abstract class TradeHistoryState {}

class TradeHistoryInitial extends TradeHistoryState {}

class TradeHistoryLoading extends TradeHistoryState {}

class TradeHistoryLoaded extends TradeHistoryState {
  final List<CoreTrade> trades;
  final Map<String, dynamic> statistics;

  TradeHistoryLoaded({required this.trades, required this.statistics});
}

class TradeHistoryError extends TradeHistoryState {
  final String message;

  TradeHistoryError(this.message);
}