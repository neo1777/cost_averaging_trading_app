// lib/features/settings/blocs/settings_state.dart

import 'package:equatable/equatable.dart';
import 'package:cost_averaging_trading_app/core/models/risk_management_settings.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final String apiKey;
  final String secretKey;
  final bool isAdvancedMode;
  final RiskManagementSettings? riskManagementSettings;

  const SettingsLoaded({
    required this.apiKey,
    required this.secretKey,
    required this.isAdvancedMode,
    this.riskManagementSettings,
  });

  SettingsLoaded copyWith({
    String? apiKey,
    String? secretKey,
    bool? isAdvancedMode,
    RiskManagementSettings? riskManagementSettings,
  }) {
    return SettingsLoaded(
      apiKey: apiKey ?? this.apiKey,
      secretKey: secretKey ?? this.secretKey,
      isAdvancedMode: isAdvancedMode ?? this.isAdvancedMode,
      riskManagementSettings: riskManagementSettings ?? this.riskManagementSettings,
    );
  }

  @override
  List<Object?> get props => [apiKey, secretKey, isAdvancedMode, riskManagementSettings];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object> get props => [message];
}