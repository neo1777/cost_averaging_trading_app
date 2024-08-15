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
  final double dailyChange;
  final double weeklyChange;

  const PortfolioLoaded({
    required this.portfolio,
    required this.performanceData,
    required this.dailyChange,
    required this.weeklyChange,
  });

  @override
  List<Object> get props =>
      [portfolio, performanceData, dailyChange, weeklyChange];
}

class PortfolioError extends PortfolioState {
  final String message;

  const PortfolioError(this.message);

  @override
  List<Object> get props => [message];
}
