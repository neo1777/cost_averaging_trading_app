// lib/features/settings/blocs/settings_event.dart

import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateApiKey extends SettingsEvent {
  final String apiKey;

  const UpdateApiKey(this.apiKey);

  @override
  List<Object> get props => [apiKey];
}

class UpdateSecretKey extends SettingsEvent {
  final String secretKey;

  const UpdateSecretKey(this.secretKey);

  @override
  List<Object> get props => [secretKey];
}

class ToggleDemoMode extends SettingsEvent {}

class ToggleBacktesting extends SettingsEvent {}

class UpdateRiskManagement extends SettingsEvent {
  final double maxLossPercentage;
  final int maxConcurrentTrades;
  final double maxPositionSizePercentage;
  final double dailyExposureLimit;
  final double maxAllowedVolatility;
  final int maxRebuyCount;

  const UpdateRiskManagement(
    this.maxLossPercentage,
    this.maxConcurrentTrades,
    this.maxPositionSizePercentage,
    this.dailyExposureLimit,
    this.maxAllowedVolatility,
    this.maxRebuyCount,
  );

  @override
  List<Object> get props => [
        maxLossPercentage,
        maxConcurrentTrades,
        maxPositionSizePercentage,
        dailyExposureLimit,
        maxAllowedVolatility,
        maxRebuyCount,
      ];
}
