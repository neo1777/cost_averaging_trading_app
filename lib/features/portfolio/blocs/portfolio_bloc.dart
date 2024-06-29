import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/core/error/error_handler.dart';
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
      emit(PortfolioLoaded(
          portfolio: portfolio, performanceData: performanceData));
    } catch (e, stackTrace) {
      ErrorHandler.logError('Error loading portfolio data', e, stackTrace);
      emit(PortfolioError(ErrorHandler.getUserFriendlyErrorMessage(e)));
    }
  }
}
