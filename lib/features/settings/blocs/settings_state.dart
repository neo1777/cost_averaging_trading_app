// lib/features/settings/blocs/settings_state.dart

import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final String apiKey;
  final String secretKey;
  final bool isDemoMode;
  final bool isBacktestingEnabled;
  final double maxLossPercentage;
  final int maxConcurrentTrades;
  final double maxPositionSizePercentage;
  final double dailyExposureLimit;
  final double maxAllowedVolatility;
  final int maxRebuyCount;

  const SettingsLoaded({
    required this.apiKey,
    required this.secretKey,
    required this.isDemoMode,
    required this.isBacktestingEnabled,
    required this.maxLossPercentage,
    required this.maxConcurrentTrades,
    required this.maxPositionSizePercentage,
    required this.dailyExposureLimit,
    required this.maxAllowedVolatility,
    required this.maxRebuyCount,
  });

  @override
  List<Object> get props => [
        apiKey,
        secretKey,
        isDemoMode,
        isBacktestingEnabled,
        maxLossPercentage,
        maxConcurrentTrades,
        maxPositionSizePercentage,
        dailyExposureLimit,
        maxAllowedVolatility,
        maxRebuyCount,
      ];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object> get props => [message];
}
