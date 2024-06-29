import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/core/error/error_handler.dart';
import 'package:cost_averaging_trading_app/features/dashboard/blocs/dashboard_event.dart';
import 'package:cost_averaging_trading_app/features/dashboard/blocs/dashboard_state.dart';
import 'package:cost_averaging_trading_app/features/dashboard/repositories/dashboard_repository.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repository;

  DashboardBloc(this._repository) : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
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
      emit(DashboardLoaded(
        portfolio: portfolio,
        recentTrades: recentTrades,
        performanceData: performanceData,
      ));
    } catch (e, stackTrace) {
      ErrorHandler.logError('Error loading dashboard data', e, stackTrace);
      emit(DashboardError(ErrorHandler.getUserFriendlyErrorMessage(e)));
    }
  }
}