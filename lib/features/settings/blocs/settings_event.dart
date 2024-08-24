// lib/features/settings/blocs/settings_event.dart

import 'package:equatable/equatable.dart';
import 'package:cost_averaging_trading_app/core/models/risk_management_settings.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateApiKey extends SettingsEvent {
  final String apiKey;

  const UpdateApiKey(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

class UpdateSecretKey extends SettingsEvent {
  final String secretKey;

  const UpdateSecretKey(this.secretKey);

  @override
  List<Object?> get props => [secretKey];
}

class ToggleAdvancedMode extends SettingsEvent {}

class UpdateRiskManagement extends SettingsEvent {
  final RiskManagementSettings settings;

  const UpdateRiskManagement(this.settings);

  @override
  List<Object?> get props => [settings];
}