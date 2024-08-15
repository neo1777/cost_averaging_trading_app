import 'package:equatable/equatable.dart';
import 'package:cost_averaging_trading_app/core/models/portfolio.dart';
import 'package:cost_averaging_trading_app/core/models/trade.dart';
import 'package:cost_averaging_trading_app/features/strategy/models/strategy_parameters.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final Portfolio portfolio;
  final List<CoreTrade> recentTrades;
  final List<Map<String, dynamic>> performanceData;
  final StrategyParameters? activeStrategy;
  final double dailyChange;
  final double dailyProfitLoss;
  final double weeklyProfitLoss;
  final double monthlyProfitLoss;

  const DashboardLoaded({
    required this.portfolio,
    required this.recentTrades,
    required this.performanceData,
    this.activeStrategy,
    required this.dailyChange,
    required this.dailyProfitLoss,
    required this.weeklyProfitLoss,
    required this.monthlyProfitLoss,
  });

  @override
  List<Object?> get props => [
        portfolio,
        recentTrades,
        performanceData,
        activeStrategy,
        dailyChange,
        dailyProfitLoss,
        weeklyProfitLoss,
        monthlyProfitLoss,
      ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}