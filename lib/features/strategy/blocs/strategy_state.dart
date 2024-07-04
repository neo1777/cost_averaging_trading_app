import 'package:equatable/equatable.dart';
import 'package:cost_averaging_trading_app/features/strategy/models/strategy_parameters.dart';
import 'package:cost_averaging_trading_app/core/services/backtesting_service.dart';

enum StrategyStateStatus { inactive, active, paused }

abstract class StrategyState extends Equatable {
  const StrategyState();

  @override
  List<Object> get props => [];
}

class StrategyInitial extends StrategyState {}

class StrategyLoading extends StrategyState {}

class StrategyLoaded extends StrategyState {
  final StrategyParameters parameters;
  final StrategyStateStatus status;
  final List<Map<String, dynamic>> chartData;
  final RiskManagementSettings riskManagementSettings;
  final BacktestResult? backtestResult;

  const StrategyLoaded({
    required this.parameters,
    required this.status,
    required this.chartData,
    required this.riskManagementSettings,
    this.backtestResult,
  });

  @override
  List<Object> get props => [
        parameters,
        status,
        chartData,
        riskManagementSettings,
        if (backtestResult != null) backtestResult!
      ];
}

class StrategyError extends StrategyState {
  final String message;

  const StrategyError(this.message);

  @override
  List<Object> get props => [message];
}

class RiskManagementSettings {
  final double maxLossPercentage;
  final int maxConcurrentTrades;
  final double maxPositionSizePercentage;
  final double dailyExposureLimit;
  final double maxAllowedVolatility;
  final int maxRebuyCount;

  const RiskManagementSettings({
    required this.maxLossPercentage,
    required this.maxConcurrentTrades,
    required this.maxPositionSizePercentage,
    required this.dailyExposureLimit,
    required this.maxAllowedVolatility,
    required this.maxRebuyCount,
  });
}

class StrategyUnsafe extends StrategyLoaded {
  final String message;
  final bool isDemo;

  StrategyUnsafe({
    required this.message,
    required StrategyParameters parameters,
    required StrategyStateStatus status,
    required List<Map<String, dynamic>> chartData,
    required RiskManagementSettings riskManagementSettings,
    required this.isDemo,
  }) : super(
          parameters: parameters,
          status: status,
          chartData: chartData,
          riskManagementSettings: riskManagementSettings,
        );

  @override
  List<Object> get props => [...super.props, message, isDemo];
}
