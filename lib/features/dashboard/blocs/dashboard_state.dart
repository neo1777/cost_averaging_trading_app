import 'package:cost_averaging_trading_app/candlestick/models/candle.dart';
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
  final List<Candle> marketData;
  final String selectedSymbol;

  const DashboardLoaded({
    required this.portfolio,
    required this.recentTrades,
    required this.performanceData,
    this.activeStrategy,
    required this.dailyChange,
    required this.dailyProfitLoss,
    required this.weeklyProfitLoss,
    required this.monthlyProfitLoss,
    required this.marketData,
    required this.selectedSymbol,
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
        marketData,
        selectedSymbol,
      ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}
