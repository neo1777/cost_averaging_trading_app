import 'package:cost_averaging_trading_app/core/services/backtesting_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/core/error/error_handler.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_event.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_state.dart';
import 'package:cost_averaging_trading_app/features/strategy/repositories/strategy_repository.dart';
import 'package:cost_averaging_trading_app/features/settings/repositories/settings_repository.dart';

class StrategyBloc extends Bloc<StrategyEvent, StrategyState> {
  final StrategyRepository _strategyRepository;
  final SettingsRepository _settingsRepository;
  final BacktestingService _backtestingService;

  StrategyBloc(this._strategyRepository, this._settingsRepository,
      this._backtestingService)
      : super(StrategyInitial()) {
    on<LoadStrategyData>(_onLoadStrategyData);
    on<UpdateStrategyParameters>(_onUpdateStrategyParameters);
    on<StartStrategy>(_onStartStrategy);
    on<StopStrategy>(_onStopStrategy);
    on<RunBacktestEvent>(_onRunBacktest);

    add(LoadStrategyData());
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
    } catch (e, stackTrace) {
      ErrorHandler.logError('Error loading strategy data', e, stackTrace);
      emit(StrategyError(ErrorHandler.getUserFriendlyErrorMessage(e)));
    }
  }

  Future<void> _onUpdateStrategyParameters(
    UpdateStrategyParameters event,
    Emitter<StrategyState> emit,
  ) async {
    if (state is StrategyLoaded) {
      final currentState = state as StrategyLoaded;
      emit(StrategyLoading());
      try {
        await _strategyRepository.updateStrategyParameters(event.parameters);
        emit(StrategyLoaded(
          parameters: event.parameters,
          status: currentState.status,
          chartData: currentState.chartData,
          riskManagementSettings: currentState.riskManagementSettings,
        ));
      } catch (e, stackTrace) {
        ErrorHandler.logError(
            'Error updating strategy parameters', e, stackTrace);
        emit(StrategyError(ErrorHandler.getUserFriendlyErrorMessage(e)));
      }
    }
  }

  Future<void> _onStartStrategy(
    StartStrategy event,
    Emitter<StrategyState> emit,
  ) async {
    if (state is StrategyLoaded) {
      final currentState = state as StrategyLoaded;
      emit(StrategyLoading());
      try {
        await _strategyRepository.startStrategy();
        emit(StrategyLoaded(
          parameters: currentState.parameters,
          status: StrategyStateStatus.active,
          chartData: currentState.chartData,
          riskManagementSettings: currentState.riskManagementSettings,
        ));
      } catch (e, stackTrace) {
        ErrorHandler.logError('Error starting strategy', e, stackTrace);
        emit(StrategyError(ErrorHandler.getUserFriendlyErrorMessage(e)));
      }
    }
  }

  Future<void> _onStopStrategy(
    StopStrategy event,
    Emitter<StrategyState> emit,
  ) async {
    if (state is StrategyLoaded) {
      final currentState = state as StrategyLoaded;
      emit(StrategyLoading());
      try {
        await _strategyRepository.stopStrategy();
        emit(StrategyLoaded(
          parameters: currentState.parameters,
          status: StrategyStateStatus.inactive,
          chartData: currentState.chartData,
          riskManagementSettings: currentState.riskManagementSettings,
        ));
      } catch (e, stackTrace) {
        ErrorHandler.logError('Error stopping strategy', e, stackTrace);
        emit(StrategyError(ErrorHandler.getUserFriendlyErrorMessage(e)));
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
        final result = await _backtestingService.runBacktest(
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
          backtestResult: result,
        ));
      } catch (e, stackTrace) {
        ErrorHandler.logError('Error running backtest', e, stackTrace);
        emit(StrategyError(ErrorHandler.getUserFriendlyErrorMessage(e)));
      }
    }
  }
}
