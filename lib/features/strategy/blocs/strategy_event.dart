import 'package:equatable/equatable.dart';
import 'package:cost_averaging_trading_app/features/strategy/models/strategy_parameters.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_state.dart';

abstract class StrategyEvent extends Equatable {
  const StrategyEvent();

  @override
  List<Object> get props => [];
}

class LoadStrategyData extends StrategyEvent {}

class UpdateStrategyParameters extends StrategyEvent {
  final StrategyParameters parameters;

  const UpdateStrategyParameters(this.parameters);

  @override
  List<Object> get props => [parameters];
}

class UpdateStrategyStatus extends StrategyEvent {
  final StrategyStateStatus status;

  const UpdateStrategyStatus(this.status);

  @override
  List<Object> get props => [status];
}

class RunBacktestEvent extends StrategyEvent {
  final DateTime startDate;
  final DateTime endDate;

  const RunBacktestEvent(this.startDate, this.endDate);

  @override
  List<Object> get props => [startDate, endDate];
}

class StartDemoStrategy extends StrategyEvent {}

class StartLiveStrategy extends StrategyEvent {}

class StopStrategy extends StrategyEvent {}

class ForceStartStrategy extends StrategyEvent {}