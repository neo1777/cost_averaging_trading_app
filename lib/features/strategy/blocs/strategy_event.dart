import 'package:cost_averaging_trading_app/core/models/trade.dart';
import 'package:equatable/equatable.dart';
import 'package:cost_averaging_trading_app/features/strategy/models/strategy_parameters.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_state.dart';

abstract class StrategyEvent extends Equatable {
  const StrategyEvent();

  @override
  List<Object?> get props => [];
}

class LoadStrategyData extends StrategyEvent {}

class UpdateStrategyParameters extends StrategyEvent {
  final StrategyParameters parameters;

  const UpdateStrategyParameters(this.parameters);

  @override
  List<Object?> get props => [parameters];
}

class UpdateStrategyStatus extends StrategyEvent {
  final StrategyStateStatus status;

  const UpdateStrategyStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class RunBacktestEvent extends StrategyEvent {
  final DateTime startDate;
  final DateTime endDate;

  const RunBacktestEvent(this.startDate, this.endDate);

  @override
  List<Object?> get props => [startDate, endDate];
}

class StartDemoStrategy extends StrategyEvent {}

class StartLiveStrategy extends StrategyEvent {}

class StopStrategy extends StrategyEvent {}

class ForceStartStrategy extends StrategyEvent {}

class SellEntirePortfolio extends StrategyEvent {
  final String symbol;
  final double targetProfit;

  const SellEntirePortfolio({required this.symbol, required this.targetProfit});

  @override
  List<Object?> get props => [symbol, targetProfit];
}

// Nuovi eventi
class UpdateUseAutoMinTradeAmount extends StrategyEvent {
  final bool useAutoMinTradeAmount;

  const UpdateUseAutoMinTradeAmount(this.useAutoMinTradeAmount);

  @override
  List<Object?> get props => [useAutoMinTradeAmount];
}

class UpdateManualMinTradeAmount extends StrategyEvent {
  final double manualMinTradeAmount;

  const UpdateManualMinTradeAmount(this.manualMinTradeAmount);

  @override
  List<Object?> get props => [manualMinTradeAmount];
}

class UpdateIsVariableInvestmentAmount extends StrategyEvent {
  final bool isVariableInvestmentAmount;

  const UpdateIsVariableInvestmentAmount(this.isVariableInvestmentAmount);

  @override
  List<Object?> get props => [isVariableInvestmentAmount];
}

class UpdateVariableInvestmentPercentage extends StrategyEvent {
  final double variableInvestmentPercentage;

  const UpdateVariableInvestmentPercentage(this.variableInvestmentPercentage);

  @override
  List<Object?> get props => [variableInvestmentPercentage];
}

class UpdateReinvestProfits extends StrategyEvent {
  final bool reinvestProfits;

  const UpdateReinvestProfits(this.reinvestProfits);

  @override
  List<Object?> get props => [reinvestProfits];
}

class StartMonitoring extends StrategyEvent {}

class StopMonitoring extends StrategyEvent {}

class UpdateMonitoringData extends StrategyEvent {
  final double? totalInvested;
  final double? currentProfit;
  final int? tradeCount;
  final double? averageBuyPrice;
  final double? currentMarketPrice;
  final List<CoreTrade>? recentTrades;

  const UpdateMonitoringData({
    this.totalInvested,
    this.currentProfit,
    this.tradeCount,
    this.averageBuyPrice,
    this.currentMarketPrice,
    this.recentTrades,
  });

  @override
  List<Object?> get props => [
        totalInvested,
        currentProfit,
        tradeCount,
        averageBuyPrice,
        currentMarketPrice,
        recentTrades
      ];
}

class StartStrategyEvent extends StrategyEvent {}

class StopStrategyEvent extends StrategyEvent {}
