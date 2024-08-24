// lib/features/settings/models/settings_model.dart

import 'package:cost_averaging_trading_app/core/models/risk_management_settings.dart';
import 'package:equatable/equatable.dart';

class SettingsModel {
  final String apiKey;
  final String secretKey;
  final bool isAdvancedMode;
  final RiskManagementSettings riskManagementSettings;

  SettingsModel({
    required this.apiKey,
    required this.secretKey,
    required this.isAdvancedMode,
    required this.riskManagementSettings,
  });

  SettingsModel copyWith({
    String? apiKey,
    String? secretKey,
    bool? isAdvancedMode,
    RiskManagementSettings? riskManagementSettings,
  }) {
    return SettingsModel(
      apiKey: apiKey ?? this.apiKey,
      secretKey: secretKey ?? this.secretKey,
      isAdvancedMode: isAdvancedMode ?? this.isAdvancedMode,
      riskManagementSettings:
          riskManagementSettings ?? this.riskManagementSettings,
    );
  }
}

class SettingsModelComplete extends Equatable {
  final double maxLossPercentage;
  final int maxConcurrentTrades;
  final double maxPositionSizePercentage;
  final double dailyExposureLimit;
  final double maxAllowedVolatility;
  final int maxRebuyCount;
  final double maxVariableInvestmentPercentage;
  final bool isDemoMode;
  final bool isBacktestingEnabled;
  final String apiKey;
  final String secretKey;

  const SettingsModelComplete({
    required this.maxLossPercentage,
    required this.maxConcurrentTrades,
    required this.maxPositionSizePercentage,
    required this.dailyExposureLimit,
    required this.maxAllowedVolatility,
    required this.maxRebuyCount,
    required this.maxVariableInvestmentPercentage,
    required this.isDemoMode,
    required this.isBacktestingEnabled,
    required this.apiKey,
    required this.secretKey,
  });

  factory SettingsModelComplete.defaultSettings() {
    return const SettingsModelComplete(
      maxLossPercentage: 2.0,
      maxConcurrentTrades: 3,
      maxPositionSizePercentage: 5.0,
      dailyExposureLimit: 1000.0,
      maxAllowedVolatility: 0.05,
      maxRebuyCount: 3,
      maxVariableInvestmentPercentage: 20.0,
      isDemoMode: true,
      isBacktestingEnabled: false,
      apiKey: '',
      secretKey: '',
    );
  }

  SettingsModelComplete copyWith({
    double? maxLossPercentage,
    int? maxConcurrentTrades,
    double? maxPositionSizePercentage,
    double? dailyExposureLimit,
    double? maxAllowedVolatility,
    int? maxRebuyCount,
    double? maxVariableInvestmentPercentage,
    bool? isDemoMode,
    bool? isBacktestingEnabled,
    String? apiKey,
    String? secretKey,
  }) {
    return SettingsModelComplete(
      maxLossPercentage: maxLossPercentage ?? this.maxLossPercentage,
      maxConcurrentTrades: maxConcurrentTrades ?? this.maxConcurrentTrades,
      maxPositionSizePercentage:
          maxPositionSizePercentage ?? this.maxPositionSizePercentage,
      dailyExposureLimit: dailyExposureLimit ?? this.dailyExposureLimit,
      maxAllowedVolatility: maxAllowedVolatility ?? this.maxAllowedVolatility,
      maxRebuyCount: maxRebuyCount ?? this.maxRebuyCount,
      maxVariableInvestmentPercentage: maxVariableInvestmentPercentage ??
          this.maxVariableInvestmentPercentage,
      isDemoMode: isDemoMode ?? this.isDemoMode,
      isBacktestingEnabled: isBacktestingEnabled ?? this.isBacktestingEnabled,
      apiKey: apiKey ?? this.apiKey,
      secretKey: secretKey ?? this.secretKey,
    );
  }

  factory SettingsModelComplete.fromJson(Map<String, dynamic> json) {
    return SettingsModelComplete(
      maxLossPercentage: json['maxLossPercentage'],
      maxConcurrentTrades: json['maxConcurrentTrades'],
      maxPositionSizePercentage: json['maxPositionSizePercentage'],
      dailyExposureLimit: json['dailyExposureLimit'],
      maxAllowedVolatility: json['maxAllowedVolatility'],
      maxRebuyCount: json['maxRebuyCount'],
      maxVariableInvestmentPercentage: json['maxVariableInvestmentPercentage'],
      isDemoMode: json['isDemoMode'],
      isBacktestingEnabled: json['isBacktestingEnabled'],
      apiKey: json['apiKey'],
      secretKey: json['secretKey'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxLossPercentage': maxLossPercentage,
      'maxConcurrentTrades': maxConcurrentTrades,
      'maxPositionSizePercentage': maxPositionSizePercentage,
      'dailyExposureLimit': dailyExposureLimit,
      'maxAllowedVolatility': maxAllowedVolatility,
      'maxRebuyCount': maxRebuyCount,
      'maxVariableInvestmentPercentage': maxVariableInvestmentPercentage,
      'isDemoMode': isDemoMode,
      'isBacktestingEnabled': isBacktestingEnabled,
      'apiKey': apiKey,
      'secretKey': secretKey,
    };
  }

  @override
  List<Object?> get props => [
        maxLossPercentage,
        maxConcurrentTrades,
        maxPositionSizePercentage,
        dailyExposureLimit,
        maxAllowedVolatility,
        maxRebuyCount,
        maxVariableInvestmentPercentage,
        isDemoMode,
        isBacktestingEnabled,
        apiKey,
        secretKey,
      ];
}
