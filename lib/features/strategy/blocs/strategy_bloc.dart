import 'dart:async';

import 'package:cost_averaging_trading_app/core/services/risk_management_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/core/services/backtesting_service.dart';
import 'package:cost_averaging_trading_app/features/settings/repositories/settings_repository.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_event.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_state.dart';
import 'package:cost_averaging_trading_app/features/strategy/repositories/strategy_repository.dart';

class StrategyBloc extends Bloc<StrategyEvent, StrategyState> {
  final StrategyRepository _strategyRepository;
  final SettingsRepository _settingsRepository;
  final BacktestingService _backtestingService;
  final RiskManagementService _riskManagementService;

  StrategyBloc(
    this._strategyRepository,
    this._settingsRepository,
    this._backtestingService,
    this._riskManagementService,
  ) : super(StrategyInitial()) {
    on<LoadStrategyData>(_onLoadStrategyData);
    on<UpdateStrategyParameters>(_onUpdateStrategyParameters);
    on<UpdateStrategyStatus>(_onUpdateStrategyStatus);
    on<RunBacktestEvent>(_onRunBacktest);
    on<StartDemoStrategy>(_onStartDemoStrategy);
    on<StartLiveStrategy>(_onStartLiveStrategy);
    on<StopStrategy>(_onStopStrategy);
    on<ForceStartStrategy>(_onForceStartStrategy);
    on<SellEntirePortfolio>(_onSellEntirePortfolio);
  }

  Future<void> _onLoadStrategyData(
    LoadStrategyData event,
    Emitter<StrategyState> emit,
  ) async {
    emit(StrategyLoading());
    try {
      final parameters = await _strategyRepository.getStrategyParameters();
      final status = await _strategyRepository.getStrategyStatus();
      final chartData = await _strategyRepository.getStrategyChartData();
      final settings = await _settingsRepository.getSettings();

      final riskManagementSettings = RiskManagementSettings(
        maxLossPercentage: settings.maxLossPercentage,
        maxConcurrentTrades: settings.maxConcurrentTrades,
        maxPositionSizePercentage: settings.maxPositionSizePercentage,
        dailyExposureLimit: settings.dailyExposureLimit,
        maxAllowedVolatility: settings.maxAllowedVolatility,
        maxRebuyCount: settings.maxRebuyCount,
      );

      emit(StrategyLoaded(
        parameters: parameters,
        status: status,
        chartData: chartData,
        riskManagementSettings: riskManagementSettings,
      ));
    } catch (e) {
      emit(StrategyError('Failed to load strategy data: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateStrategyParameters(
    UpdateStrategyParameters event,
    Emitter<StrategyState> emit,
  ) async {
    if (state is StrategyLoaded) {
      final currentState = state as StrategyLoaded;
      try {
        await _strategyRepository.updateStrategyParameters(event.parameters);
        emit(StrategyLoaded(
          parameters: event.parameters,
          status: currentState.status,
          chartData: currentState.chartData,
          riskManagementSettings: currentState.riskManagementSettings,
        ));
      } catch (e) {
        emit(StrategyError(
            'Failed to update strategy parameters: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateStrategyStatus(
    UpdateStrategyStatus event,
    Emitter<StrategyState> emit,
  ) async {
    if (state is StrategyLoaded) {
      final currentState = state as StrategyLoaded;
      try {
        await _strategyRepository.saveStrategyStatus(event.status);
        emit(StrategyLoaded(
          parameters: currentState.parameters,
          status: event.status,
          chartData: currentState.chartData,
          riskManagementSettings: currentState.riskManagementSettings,
        ));
      } catch (e) {
        emit(
            StrategyError('Failed to update strategy status: ${e.toString()}'));
      }
    }
  }

Future<void> _onRunBacktest(
  RunBacktestEvent event,
  Emitter<StrategyState> emit,
) async {
  if (state is StrategyLoaded) {
    final currentState = state as StrategyLoaded;
    emit(StrategyLoading());
    try {
      final backtestResult = await _backtestingService.runBacktest(
        currentState.parameters.symbol,
        event.startDate,
        event.endDate,
        currentState.parameters,
      );
      emit(StrategyLoaded(
        parameters: currentState.parameters,
        status: currentState.status,
        chartData: currentState.chartData,
        riskManagementSettings: currentState.riskManagementSettings,
        backtestResult: backtestResult,
      ));
    } catch (e) {
      emit(StrategyError('Failed to run backtest: ${e.toString()}'));
    }
  }
}

  Future<void> _onStartDemoStrategy(
    StartDemoStrategy event,
    Emitter<StrategyState> emit,
  ) async {
    if (state is StrategyLoaded) {
      final currentState = state as StrategyLoaded;
      try {
        bool isStrategySafe = await _riskManagementService
            .isStrategySafe(currentState.parameters);
        if (!isStrategySafe) {
          emit(StrategyUnsafe(
            message:
                'Strategy is not safe to start based on current risk management settings.',
            parameters: currentState.parameters,
            status: currentState.status,
            chartData: currentState.chartData,
            riskManagementSettings: currentState.riskManagementSettings,
            isDemo: true,
          ));
          return;
        }

        await _startStrategy(currentState, isDemo: true, emit: emit);
      } catch (e) {
        emit(StrategyError('Failed to start demo strategy: ${e.toString()}'));
      }
    }
  }

  Future<void> _onStartLiveStrategy(
    StartLiveStrategy event,
    Emitter<StrategyState> emit,
  ) async {
    if (state is StrategyLoaded) {
      final currentState = state as StrategyLoaded;
      try {
        bool isStrategySafe = await _riskManagementService
            .isStrategySafe(currentState.parameters);
        if (!isStrategySafe) {
          emit(StrategyUnsafe(
            message:
                'Strategy is not safe to start based on current risk management settings.',
            parameters: currentState.parameters,
            status: currentState.status,
            chartData: currentState.chartData,
            riskManagementSettings: currentState.riskManagementSettings,
            isDemo: false,
          ));
          return;
        }

        await _startStrategy(currentState, isDemo: false, emit: emit);
      } catch (e) {
        emit(StrategyError('Failed to start live strategy: ${e.toString()}'));
      }
    }
  }

  Future<void> _startStrategy(StrategyLoaded currentState,
      {required bool isDemo, required Emitter<StrategyState> emit}) async {
    try {
      if (isDemo) {
        await _strategyRepository.startDemoStrategy(currentState.parameters);
      } else {
        await _strategyRepository.startLiveStrategy(currentState.parameters);
      }
      emit(StrategyLoaded(
        parameters: currentState.parameters,
        status: StrategyStateStatus.active,
        chartData: currentState.chartData,
        riskManagementSettings: currentState.riskManagementSettings,
      ));
    } catch (e) {
      if (e.toString().contains('Trade not allowed')) {
        emit(StrategyError(
            'Strategy not started: Trade not allowed due to risk limits'));
      } else {
        emit(StrategyError('Failed to start strategy: ${e.toString()}'));
      }
    }
  }

  // Add this new event handler
  Future<void> _onForceStartStrategy(
    ForceStartStrategy event,
    Emitter<StrategyState> emit,
  ) async {
    if (state is StrategyUnsafe) {
      final currentState = state as StrategyUnsafe;
      await _startStrategy(currentState,
          isDemo: currentState.isDemo, emit: emit);
    }
  }

  Future<void> _onStopStrategy(
    StopStrategy event,
    Emitter<StrategyState> emit,
  ) async {
    print('Stopping strategy');
    if (state is StrategyLoaded) {
      final currentState = state as StrategyLoaded;
      try {
        await _strategyRepository.stopStrategy();
        print('Strategy stopped successfully');
        emit(StrategyLoaded(
          parameters: currentState.parameters,
          status: StrategyStateStatus.inactive,
          chartData: currentState.chartData,
          riskManagementSettings: currentState.riskManagementSettings,
        ));
      } catch (e) {
        print('Error in _onStopStrategy: $e');
        emit(StrategyError('Failed to stop strategy: ${e.toString()}'));
      }
    } else {
      print('Cannot stop strategy: not in loaded state');
    }
  }

  Future<void> _onSellEntirePortfolio(
    SellEntirePortfolio event,
    Emitter<StrategyState> emit,
  ) async {
    if (state is StrategyLoaded) {
      final currentState = state as StrategyLoaded;
      try {
        await _strategyRepository.sellEntirePortfolio(
            event.symbol, event.targetProfit);
        emit(StrategyLoaded(
          parameters: currentState.parameters,
          status: StrategyStateStatus.inactive,
          chartData: currentState.chartData,
          riskManagementSettings: currentState.riskManagementSettings,
        ));
      } catch (e) {
        emit(StrategyError('Failed to sell entire portfolio: ${e.toString()}'));
      }
    }
  }
}
