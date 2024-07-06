import 'package:cost_averaging_trading_app/core/models/risk_management_settings.dart';
import 'package:cost_averaging_trading_app/core/models/trade.dart';
import 'package:equatable/equatable.dart';
import 'package:cost_averaging_trading_app/features/strategy/models/strategy_parameters.dart';
import 'package:cost_averaging_trading_app/core/services/backtesting_service.dart';

enum StrategyStateStatus { inactive, active, paused, backtesting }

abstract class StrategyState extends Equatable {
  const StrategyState();

  @override
  List<Object?> get props => [];
}

class StrategyInitial extends StrategyState {}

class StrategyLoading extends StrategyState {}

class StrategyLoaded extends StrategyState {
  final StrategyParameters parameters;
  final StrategyStateStatus status;
  final List<Map<String, dynamic>> chartData;
  final RiskManagementSettings riskManagementSettings;
  final BacktestResult? backtestResult;
  final double totalInvested;
  final double currentProfit;
  final int tradeCount;
  final double averageBuyPrice;
  final double currentMarketPrice;
  final List<CoreTrade> recentTrades;
  final bool isDemo;


  const StrategyLoaded({
    required this.parameters,
    required this.status,
    required this.chartData,
    required this.riskManagementSettings,
    this.backtestResult,
    this.totalInvested = 0,
    this.currentProfit = 0,
    this.tradeCount = 0,
    this.averageBuyPrice = 0,
    this.currentMarketPrice = 0,
    this.recentTrades = const [],
        this.isDemo = false,

  });

  StrategyLoaded copyWith({
    StrategyParameters? parameters,
    StrategyStateStatus? status,
    List<Map<String, dynamic>>? chartData,
    RiskManagementSettings? riskManagementSettings,
    BacktestResult? backtestResult,
    double? totalInvested,
    double? currentProfit,
    int? tradeCount,
    double? averageBuyPrice,
    double? currentMarketPrice,
    List<CoreTrade>? recentTrades,
        bool? isDemo,

  }) {
    return StrategyLoaded(
      parameters: parameters ?? this.parameters,
      status: status ?? this.status,
      chartData: chartData ?? this.chartData,
      riskManagementSettings: riskManagementSettings ?? this.riskManagementSettings,
      backtestResult: backtestResult ?? this.backtestResult,
      totalInvested: totalInvested ?? this.totalInvested,
      currentProfit: currentProfit ?? this.currentProfit,
      tradeCount: tradeCount ?? this.tradeCount,
      averageBuyPrice: averageBuyPrice ?? this.averageBuyPrice,
      currentMarketPrice: currentMarketPrice ?? this.currentMarketPrice,
      recentTrades: recentTrades ?? this.recentTrades,
            isDemo: isDemo ?? this.isDemo,

    );
  }

  @override
  List<Object?> get props => [
        parameters,
        status,
        chartData,
        riskManagementSettings,
        backtestResult,
        totalInvested,
        currentProfit,
        tradeCount,
        averageBuyPrice,
        currentMarketPrice,
        recentTrades
      ];
}

class StrategyError extends StrategyState {
  final String message;

  const StrategyError(this.message);

  @override
  List<Object> get props => [message];
}

class StrategyUnsafe extends StrategyLoaded {
  final String message;
  
  final bool isNowDemo;

  const StrategyUnsafe({
    required this.message,
    required super.parameters,
    required super.status,
    required super.chartData,
    required super.riskManagementSettings,
    required this.isNowDemo,
  });

  @override
  List<Object> get props => [super.props, message, isNowDemo];
}
