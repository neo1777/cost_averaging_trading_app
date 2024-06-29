import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/core/error/error_handler.dart';
import 'package:cost_averaging_trading_app/features/dashboard/blocs/dashboard_event.dart';
import 'package:cost_averaging_trading_app/features/dashboard/blocs/dashboard_state.dart';
import 'package:cost_averaging_trading_app/features/dashboard/repositories/dashboard_repository.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repository;

  DashboardBloc(this._repository) : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<LoadMoreTrades>(_onLoadMoreTrades);
    on<ChangeTradesPerPage>(_onChangeTradesPerPage);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final portfolio = await _repository.getPortfolio();
      final recentTrades =
          await _repository.getRecentTrades(page: 1, perPage: 10);
      final performanceData = await _repository.getPerformanceData();


      emit(DashboardLoaded(
        portfolio: portfolio,
        recentTrades: recentTrades,
        performanceData: performanceData,
        currentPage: 1,
        tradesPerPage: 10,
      ));
    } catch (e, stackTrace) {
      ErrorHandler.logError('Error loading dashboard data', e, stackTrace);
      emit(DashboardError(ErrorHandler.getUserFriendlyErrorMessage(e)));
    }
  }

  Future<void> _onLoadMoreTrades(
    LoadMoreTrades event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      try {
        final nextPage = currentState.currentPage + 1;
        final newTrades = await _repository.getRecentTrades(
          page: nextPage,
          perPage: currentState.tradesPerPage,
        );
        emit(currentState.copyWith(
          recentTrades: [...currentState.recentTrades, ...newTrades],
          currentPage: nextPage,
        ));
      } catch (e, stackTrace) {
        ErrorHandler.logError('Error loading more trades', e, stackTrace);
      }
    }
  }

  Future<void> _onChangeTradesPerPage(
    ChangeTradesPerPage event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      try {
        final newTrades = await _repository.getRecentTrades(
          page: 1,
          perPage: event.tradesPerPage,
        );
        emit(currentState.copyWith(
          recentTrades: newTrades,
          currentPage: 1,
          tradesPerPage: event.tradesPerPage,
        ));
      } catch (e, stackTrace) {
        ErrorHandler.logError('Error changing trades per page', e, stackTrace);
      }
    }
  }
}
