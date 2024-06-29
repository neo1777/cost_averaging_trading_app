import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_event.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_state.dart';
import 'package:cost_averaging_trading_app/features/strategy/repositories/strategy_repository.dart';
import 'package:cost_averaging_trading_app/features/settings/repositories/settings_repository.dart';
import 'package:cost_averaging_trading_app/core/services/backtesting_service.dart';

class StrategyBloc extends Bloc<StrategyEvent, StrategyState> {
  final StrategyRepository _strategyRepository;
  final SettingsRepository _settingsRepository;
  final BacktestingService _backtestingService;

  StrategyBloc(
    this._strategyRepository,
    this._settingsRepository,
    this._backtestingService,
  ) : super(StrategyInitial()) {
    on<LoadStrategyData>(_onLoadStrategyData);
    on<UpdateStrategyParameters>(_onUpdateStrategyParameters);
    on<UpdateStrategyStatus>(_onUpdateStrategyStatus);
    on<RunBacktestEvent>(_onRunBacktest);
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
}
