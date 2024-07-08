import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cost_averaging_trading_app/features/dashboard/blocs/dashboard_event.dart';
import 'package:cost_averaging_trading_app/features/dashboard/blocs/dashboard_state.dart';
import 'package:cost_averaging_trading_app/features/dashboard/repositories/dashboard_repository.dart';
import 'package:cost_averaging_trading_app/features/strategy/repositories/strategy_repository.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repository;
  final StrategyRepository _strategyRepository;

  DashboardBloc(this._repository, this._strategyRepository) : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<ChangePage>(_onChangePage);
    on<ChangeTradesPerPage>(_onChangeTradesPerPage);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final portfolio = await _repository.getPortfolio();
      final recentTrades = await _repository.getRecentTrades();
      final performanceData = await _repository.getPerformanceData();
      final activeStrategy = await _strategyRepository.getActiveStrategy();

      emit(DashboardLoaded(
        portfolio: portfolio,
        recentTrades: recentTrades,
        performanceData: performanceData,
        currentPage: 1,
        tradesPerPage: 10,
        activeStrategy: activeStrategy, // Aggiungi questa riga
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  void _onChangePage(
    ChangePage event,
    Emitter<DashboardState> emit,
  ) {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      emit(currentState.copyWith(currentPage: event.newPage));
    }
  }

  void _onChangeTradesPerPage(
    ChangeTradesPerPage event,
    Emitter<DashboardState> emit,
  ) {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      emit(currentState.copyWith(
        tradesPerPage: event.tradesPerPage,
        currentPage: 1, // Reset to first page when changing trades per page
      ));
    }
  }
}
