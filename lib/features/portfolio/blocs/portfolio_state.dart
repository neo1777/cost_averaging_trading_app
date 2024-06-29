// lib/features/portfolio/blocs/portfolio_state.dart

import 'package:cost_averaging_trading_app/core/models/portfolio.dart';
import 'package:equatable/equatable.dart';

abstract class PortfolioState extends Equatable {
  const PortfolioState();

  @override
  List<Object> get props => [];
}

class PortfolioInitial extends PortfolioState {}

class PortfolioLoading extends PortfolioState {}

class PortfolioLoaded extends PortfolioState {
  final Portfolio portfolio;
  final List<Map<String, dynamic>> performanceData;

  const PortfolioLoaded({
    required this.portfolio,
    required this.performanceData,
  });

  @override
  List<Object> get props => [portfolio, performanceData];
}

class PortfolioError extends PortfolioState {
  final String message;

  const PortfolioError(this.message);

  @override
  List<Object> get props => [message];
}
