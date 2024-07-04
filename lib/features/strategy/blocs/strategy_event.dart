import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_state.dart';
import 'package:cost_averaging_trading_app/features/strategy/models/strategy_parameters.dart';

abstract class StrategyEvent {}

class LoadStrategyData extends StrategyEvent {}

class UpdateStrategyParameters extends StrategyEvent {
  final StrategyParameters parameters;

  UpdateStrategyParameters(this.parameters);
}

class UpdateStrategyStatus extends StrategyEvent {
  final StrategyStateStatus status;

  UpdateStrategyStatus(this.status);
}

class RunBacktestEvent extends StrategyEvent {
  final DateTime startDate;
  final DateTime endDate;

  RunBacktestEvent(this.startDate, this.endDate);
}

class StartDemoStrategy extends StrategyEvent {}

class StartLiveStrategy extends StrategyEvent {}

class StopStrategy extends StrategyEvent {}

class ForceStartStrategy extends StrategyEvent {}

class SellEntirePortfolio extends StrategyEvent {
  final String symbol;
  final double targetProfit;

  SellEntirePortfolio({required this.symbol, required this.targetProfit});
}
