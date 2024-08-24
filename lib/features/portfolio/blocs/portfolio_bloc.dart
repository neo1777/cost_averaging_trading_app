import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/features/portfolio/blocs/portfolio_event.dart';
import 'package:cost_averaging_trading_app/features/portfolio/blocs/portfolio_state.dart';
import 'package:cost_averaging_trading_app/features/portfolio/repositories/portfolio_repository.dart';

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final PortfolioRepository _repository;

  PortfolioBloc(this._repository) : super(PortfolioInitial()) {
    on<LoadPortfolio>(_onLoadPortfolio);
  }

  Future<void> _onLoadPortfolio(
    LoadPortfolio event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(PortfolioLoading());
    try {
      final portfolio = await _repository.getPortfolio();
      final performanceData = await _repository.getPerformanceData();
      final dailyChange = await _repository.getDailyChange();
      final weeklyChange = await _repository.getWeeklyChange();
      
      if (portfolio.totalValue == 0 && performanceData.isEmpty) {
        emit(PortfolioEmpty());
      } else {
        emit(PortfolioLoaded(
          portfolio: portfolio,
          performanceData: performanceData,
          dailyChange: dailyChange,
          weeklyChange: weeklyChange,
        ));
      }
    } catch (e) {
      emit(const PortfolioError("Si è verificato un errore imprevisto. Per favore, riprova più tardi."));
    }
  }
}