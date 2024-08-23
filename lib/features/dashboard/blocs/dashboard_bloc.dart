import 'package:flutter_bloc/flutter_bloc.dart';
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
      final activeStrategy = await _repository.getActiveStrategy();
      final dailyChange = await _repository.getDailyChange();
      final dailyProfitLoss = await _repository.getDailyProfitLoss();
      final weeklyProfitLoss = await _repository.getWeeklyProfitLoss();
      final monthlyProfitLoss = await _repository.getMonthlyProfitLoss();
      final marketData = await _repository.getMarketData('BTCUSDT');
      const selectedSymbol = 'BTCUSDT';

      emit(DashboardLoaded(
          portfolio: portfolio,
          recentTrades: recentTrades,
          performanceData: performanceData,
          activeStrategy: activeStrategy,
          dailyChange: dailyChange,
          dailyProfitLoss: dailyProfitLoss,
          weeklyProfitLoss: weeklyProfitLoss,
          monthlyProfitLoss: monthlyProfitLoss,
          marketData: marketData,
          selectedSymbol: selectedSymbol));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
