import 'package:cost_averaging_trading_app/core/models/trade.dart';

abstract class TradeHistoryState {}

class TradeHistoryInitial extends TradeHistoryState {}

class TradeHistoryLoading extends TradeHistoryState {}

class TradeHistoryLoaded extends TradeHistoryState {
  final List<CoreTrade> trades;
  final Map<String, dynamic> statistics;
  final int currentPage;
  final int totalPages;

  TradeHistoryLoaded({
    required this.trades,
    required this.statistics,
    required this.currentPage,
    required this.totalPages,
  });
}

class TradeHistoryError extends TradeHistoryState {
  final String message;

  TradeHistoryError(this.message);
}
