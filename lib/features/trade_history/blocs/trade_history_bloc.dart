import 'package:cost_averaging_trading_app/core/models/trade.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/core/error/error_handler.dart';
import 'package:cost_averaging_trading_app/features/trade_history/blocs/trade_history_event.dart';
import 'package:cost_averaging_trading_app/features/trade_history/blocs/trade_history_state.dart';
import 'package:cost_averaging_trading_app/features/trade_history/repositories/trade_history_repository.dart';

class TradeHistoryBloc extends Bloc<TradeHistoryEvent, TradeHistoryState> {
  final TradeHistoryRepository _repository;

  TradeHistoryBloc(this._repository) : super(TradeHistoryInitial()) {
    on<LoadTradeHistory>(_onLoadTradeHistory);
    on<FilterTradeHistory>(_onFilterTradeHistory);

    // Aggiungiamo questa riga per caricare i dati all'inizializzazione
    add(LoadTradeHistory());
  }

  Future<void> _onLoadTradeHistory(
    LoadTradeHistory event,
    Emitter<TradeHistoryState> emit,
  ) async {
    emit(TradeHistoryLoading());
    try {
      final trades = await _repository.getTradeHistory();
      final statistics = _calculateStatistics(trades);
      emit(TradeHistoryLoaded(trades: trades, statistics: statistics));
    } catch (e, stackTrace) {
      ErrorHandler.logError('Error loading trade history', e, stackTrace);
      emit(TradeHistoryError(ErrorHandler.getUserFriendlyErrorMessage(e)));
    }
  }

  Future<void> _onFilterTradeHistory(
    FilterTradeHistory event,
    Emitter<TradeHistoryState> emit,
  ) async {
    emit(TradeHistoryLoading());
    try {
      final trades = await _repository.getFilteredTradeHistory(
        startDate: event.startDate,
        endDate: event.endDate,
        assetPair: event.assetPair,
      );
      final statistics = _calculateStatistics(trades);
      emit(TradeHistoryLoaded(trades: trades, statistics: statistics));
    } catch (e, stackTrace) {
      ErrorHandler.logError('Error filtering trade history', e, stackTrace);
      emit(TradeHistoryError(ErrorHandler.getUserFriendlyErrorMessage(e)));
    }
  }

  Map<String, dynamic> _calculateStatistics(List<CoreTrade> trades) {
    final totalTrades = trades.length;
    final buyTrades =
        trades.where((trade) => trade.type.name.toLowerCase() == 'buy').length;
    final sellTrades = totalTrades - buyTrades;

    double totalVolume = 0;
    double totalProfit = 0;
    Map<String, double> assetVolumes = {};

    for (var trade in trades) {
      final tradeVolume = trade.amount * trade.price;
      totalVolume += tradeVolume;

      if (trade.type.name.toLowerCase() == 'sell') {
        totalProfit += tradeVolume;
      } else {
        totalProfit -= tradeVolume;
      }

      assetVolumes[trade.symbol] =
          (assetVolumes[trade.symbol] ?? 0) + tradeVolume;
    }

    return {
      'totalTrades': totalTrades,
      'buyTrades': buyTrades,
      'sellTrades': sellTrades,
      'totalVolume': totalVolume,
      'totalProfit': totalProfit,
      'assetVolumes': assetVolumes,
    };
  }
}
