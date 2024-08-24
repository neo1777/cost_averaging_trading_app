import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/features/settings/blocs/settings_event.dart';
import 'package:cost_averaging_trading_app/features/settings/blocs/settings_state.dart';
import 'package:cost_averaging_trading_app/features/settings/repositories/settings_repository.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repository;

  SettingsBloc(this._repository) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateApiKey>(_onUpdateApiKey);
    on<UpdateSecretKey>(_onUpdateSecretKey);
    on<ToggleAdvancedMode>(_onToggleAdvancedMode); // Aggiungi questa riga

    on<UpdateRiskManagement>(_onUpdateRiskManagement);
    add(LoadSettings());
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final settings = await _repository.getSettings();
      emit(SettingsLoaded(
        apiKey: settings.apiKey,
        secretKey: settings.secretKey,
        isAdvancedMode: settings.isAdvancedMode,
        riskManagementSettings: settings.riskManagementSettings,
      ));
    } catch (e) {
      emit(SettingsError('Failed to load settings: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateApiKey(
    UpdateApiKey event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      try {
        await _repository.updateApiKey(event.apiKey);
        emit((state as SettingsLoaded).copyWith(apiKey: event.apiKey));
      } catch (e) {
        emit(SettingsError('Failed to update API key: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateSecretKey(
    UpdateSecretKey event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      try {
        await _repository.updateSecretKey(event.secretKey);
        emit((state as SettingsLoaded).copyWith(secretKey: event.secretKey));
      } catch (e) {
        emit(SettingsError('Failed to update Secret key: ${e.toString()}'));
      }
    }
  }

  Future<void> _onToggleAdvancedMode(
    ToggleAdvancedMode event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      try {
        final newAdvancedMode = !currentState.isAdvancedMode;
        await _repository.updateAdvancedMode(newAdvancedMode);
        emit(currentState.copyWith(isAdvancedMode: newAdvancedMode));
      } catch (e) {
        emit(SettingsError('Failed to toggle advanced mode: ${e.toString()}'));
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
        await _repository.updateRiskManagement(event.settings);
        emit(currentState.copyWith(riskManagementSettings: event.settings));
      } catch (e) {
        emit(SettingsError(
            'Failed to update risk management settings: ${e.toString()}'));
      }
    }
  }
}
