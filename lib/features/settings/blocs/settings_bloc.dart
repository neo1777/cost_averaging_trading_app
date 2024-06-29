import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/core/error/error_handler.dart';
import 'package:cost_averaging_trading_app/features/settings/blocs/settings_event.dart';
import 'package:cost_averaging_trading_app/features/settings/blocs/settings_state.dart';
import 'package:cost_averaging_trading_app/features/settings/repositories/settings_repository.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repository;

  SettingsBloc(this._repository) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateApiKey>(_onUpdateApiKey);
    on<UpdateSecretKey>(_onUpdateSecretKey);
    on<ToggleDemoMode>(_onToggleDemoMode);
    on<ToggleBacktesting>(_onToggleBacktesting);
    on<UpdateRiskManagement>(_onUpdateRiskManagement);
    add(LoadSettings());
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final settings = await _repository.getSettings();
      emit(SettingsLoaded(
        apiKey: settings.apiKey,
        secretKey: settings.secretKey,
        isDemoMode: settings.isDemoMode,
        isBacktestingEnabled: settings.isBacktestingEnabled,
        maxLossPercentage: settings.maxLossPercentage,
        maxConcurrentTrades: settings.maxConcurrentTrades,
        maxPositionSizePercentage: settings.maxPositionSizePercentage,
        dailyExposureLimit: settings.dailyExposureLimit,
        maxAllowedVolatility: settings.maxAllowedVolatility,
        maxRebuyCount: settings.maxRebuyCount,
      ));
    } catch (e, stackTrace) {
      ErrorHandler.logError('Error loading settings', e, stackTrace);
      emit(SettingsError(ErrorHandler.getUserFriendlyErrorMessage(e)));
    }
  }

  Future<void> _onUpdateApiKey(
    UpdateApiKey event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      try {
        await _repository.updateApiKey(event.apiKey);
        emit(SettingsLoaded(
          apiKey: event.apiKey,
          secretKey: currentState.secretKey,
          isDemoMode: currentState.isDemoMode,
          isBacktestingEnabled: currentState.isBacktestingEnabled,
          maxLossPercentage: currentState.maxLossPercentage,
          maxConcurrentTrades: currentState.maxConcurrentTrades,
          maxPositionSizePercentage: currentState.maxPositionSizePercentage,
          dailyExposureLimit: currentState.dailyExposureLimit,
          maxAllowedVolatility: currentState.maxAllowedVolatility,
          maxRebuyCount: currentState.maxRebuyCount,
        ));
      } catch (e, stackTrace) {
        ErrorHandler.logError('Error updating API key', e, stackTrace);
        emit(SettingsError(ErrorHandler.getUserFriendlyErrorMessage(e)));
      }
    }
  }

  Future<void> _onUpdateSecretKey(
    UpdateSecretKey event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      try {
        await _repository.updateSecretKey(event.secretKey);
        emit(SettingsLoaded(
          apiKey: currentState.apiKey,
          secretKey: event.secretKey,
          isDemoMode: currentState.isDemoMode,
          isBacktestingEnabled: currentState.isBacktestingEnabled,
          maxLossPercentage: currentState.maxLossPercentage,
          maxConcurrentTrades: currentState.maxConcurrentTrades,
          maxPositionSizePercentage: currentState.maxPositionSizePercentage,
          dailyExposureLimit: currentState.dailyExposureLimit,
          maxAllowedVolatility: currentState.maxAllowedVolatility,
          maxRebuyCount: currentState.maxRebuyCount,
        ));
      } catch (e, stackTrace) {
        ErrorHandler.logError('Error updating Secret key', e, stackTrace);
        emit(SettingsError(ErrorHandler.getUserFriendlyErrorMessage(e)));
      }
    }
  }

  Future<void> _onToggleDemoMode(
    ToggleDemoMode event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      try {
        final newDemoMode = !currentState.isDemoMode;
        await _repository.updateDemoMode(newDemoMode);
        emit(SettingsLoaded(
          apiKey: currentState.apiKey,
          secretKey: currentState.secretKey,
          isDemoMode: newDemoMode,
          isBacktestingEnabled: currentState.isBacktestingEnabled,
          maxLossPercentage: currentState.maxLossPercentage,
          maxConcurrentTrades: currentState.maxConcurrentTrades,
          maxPositionSizePercentage: currentState.maxPositionSizePercentage,
          dailyExposureLimit: currentState.dailyExposureLimit,
          maxAllowedVolatility: currentState.maxAllowedVolatility,
          maxRebuyCount: currentState.maxRebuyCount,
        ));
      } catch (e, stackTrace) {
        ErrorHandler.logError('Error toggle demoMode settings', e, stackTrace);
        emit(SettingsError(ErrorHandler.getUserFriendlyErrorMessage(e)));
      }
    }
  }

  Future<void> _onToggleBacktesting(
    ToggleBacktesting event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      try {
        final newBacktestingMode = !currentState.isBacktestingEnabled;
        await _repository.updateBacktestingMode(newBacktestingMode);
        emit(SettingsLoaded(
          apiKey: currentState.apiKey,
          secretKey: currentState.secretKey,
          isDemoMode: currentState.isDemoMode,
          isBacktestingEnabled: newBacktestingMode,
          maxLossPercentage: currentState.maxLossPercentage,
          maxConcurrentTrades: currentState.maxConcurrentTrades,
          maxPositionSizePercentage: currentState.maxPositionSizePercentage,
          dailyExposureLimit: currentState.dailyExposureLimit,
          maxAllowedVolatility: currentState.maxAllowedVolatility,
          maxRebuyCount: currentState.maxRebuyCount,
        ));
      } catch (e, stackTrace) {
        ErrorHandler.logError(
            'Error toggle backtesting settings', e, stackTrace);
        emit(SettingsError(ErrorHandler.getUserFriendlyErrorMessage(e)));
      }
    }
  }

  Future<void> _onUpdateRiskManagement(
    UpdateRiskManagement event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      try {
        await _repository.updateRiskManagement(
          maxLossPercentage: event.maxLossPercentage,
          maxConcurrentTrades: event.maxConcurrentTrades,
          maxPositionSizePercentage: event.maxPositionSizePercentage,
          dailyExposureLimit: event.dailyExposureLimit,
          maxAllowedVolatility: event.maxAllowedVolatility,
          maxRebuyCount: event.maxRebuyCount,
        );
        emit(SettingsLoaded(
          apiKey: currentState.apiKey,
          secretKey: currentState.secretKey,
          isDemoMode: currentState.isDemoMode,
          isBacktestingEnabled: currentState.isBacktestingEnabled,
          maxLossPercentage: event.maxLossPercentage,
          maxConcurrentTrades: event.maxConcurrentTrades,
          maxPositionSizePercentage: event.maxPositionSizePercentage,
          dailyExposureLimit: event.dailyExposureLimit,
          maxAllowedVolatility: event.maxAllowedVolatility,
          maxRebuyCount: event.maxRebuyCount,
        ));
      } catch (e, stackTrace) {
        ErrorHandler.logError(
            'Error updating risk management settings', e, stackTrace);
        emit(SettingsError(ErrorHandler.getUserFriendlyErrorMessage(e)));
      }
    }
  }
}
