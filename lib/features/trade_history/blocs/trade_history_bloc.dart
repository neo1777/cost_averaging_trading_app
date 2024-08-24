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
    on<ChangePage>(_onChangePage);
    add(LoadTradeHistory());
  }

  Future<void> _onLoadTradeHistory(
    LoadTradeHistory event,
    Emitter<TradeHistoryState> emit,
  ) async {
    emit(TradeHistoryLoading());
    try {
      final result = await _repository.getTradeHistory();
      emit(_createLoadedState(result, 1));
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
      final result = await _repository.getFilteredTradeHistory(
        startDate: event.startDate,
        endDate: event.endDate,
        assetPair: event.assetPair,
      );
      emit(_createLoadedState(result, 1));
    } catch (e, stackTrace) {
      ErrorHandler.logError('Error filtering trade history', e, stackTrace);
      emit(TradeHistoryError(ErrorHandler.getUserFriendlyErrorMessage(e)));
    }
  }

  Future<void> _onChangePage(
    ChangePage event,
    Emitter<TradeHistoryState> emit,
  ) async {
    if (state is TradeHistoryLoaded) {
      final currentState = state as TradeHistoryLoaded;
      emit(TradeHistoryLoading());
      try {
        final result = await _repository.getTradeHistoryPage(event.pageNumber);
        emit(_createLoadedState(
            result, event.pageNumber, currentState.totalPages));
      } catch (e, stackTrace) {
        ErrorHandler.logError('Error changing page', e, stackTrace);
        emit(TradeHistoryError(ErrorHandler.getUserFriendlyErrorMessage(e)));
      }
    }
  }

  TradeHistoryLoaded _createLoadedState(
      TradeHistoryResult result, int currentPage,
      [int? totalPages]) {
    return TradeHistoryLoaded(
      trades: result.trades,
      statistics: {
        'totalTrades': result.statistics['totalTrades'] ?? 0,
        'profitableTrades': result.statistics['profitableTrades'] ?? 0,
        'totalProfit': result.statistics['totalProfit'] ?? 0.0,
        'winRate': result.statistics['winRate'] ?? 0.0,
        'averageProfit': result.statistics['averageProfit'] ?? 0.0,
        'averageLoss': result.statistics['averageLoss'] ?? 0.0,
        'assetVolumes':
            (result.statistics['assetVolumes'] as Map<dynamic, dynamic>?)?.map(
                  (key, value) =>
                      MapEntry(key.toString(), (value as num).toDouble()),
                ) ??
                {},
      },
      currentPage: currentPage,
      totalPages: totalPages ?? result.totalPages,
    );
  }
}
