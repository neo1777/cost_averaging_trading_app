class SettingsModel {
  final String apiKey;
  final String secretKey;
  final bool isBacktestingMode;
  final double maxLossPercentage;
  final int maxConcurrentTrades;
  final bool isDemoMode;
  final double maxPositionSizePercentage;
  final double dailyExposureLimit;
  // Nuove proprietà aggiunte
  final double maxAllowedVolatility;
  final int maxRebuyCount;

  SettingsModel({
    required this.apiKey,
    required this.secretKey,
    required this.isBacktestingMode,
    required this.maxLossPercentage,
    required this.maxConcurrentTrades,
    required this.isDemoMode,
    required this.maxPositionSizePercentage,
    required this.dailyExposureLimit,
    required this.maxAllowedVolatility,
    required this.maxRebuyCount,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      apiKey: json['apiKey'] as String,
      secretKey: json['secretKey'] as String,
      isBacktestingMode: json['isBacktestingMode'] as bool,
      maxLossPercentage: json['maxLossPercentage'] as double,
      maxConcurrentTrades: json['maxConcurrentTrades'] as int,
      isDemoMode: json['isDemoMode'] as bool,
      maxPositionSizePercentage: json['maxPositionSizePercentage'] as double,
      dailyExposureLimit: json['dailyExposureLimit'] as double,
      maxAllowedVolatility: json['maxAllowedVolatility'] as double,
      maxRebuyCount: json['maxRebuyCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'apiKey': apiKey,
      'secretKey': secretKey,
      'isBacktestingMode': isBacktestingMode,
      'maxLossPercentage': maxLossPercentage,
      'maxConcurrentTrades': maxConcurrentTrades,
      'isDemoMode': isDemoMode,
      'maxPositionSizePercentage': maxPositionSizePercentage,
      'dailyExposureLimit': dailyExposureLimit,
      'maxAllowedVolatility': maxAllowedVolatility,
      'maxRebuyCount': maxRebuyCount,
    };
  }

  SettingsModel copyWith({
    String? apiKey,
    String? secretKey,
    bool? isBacktestingMode,
    double? maxLossPercentage,
    int? maxConcurrentTrades,
    bool? isDemoMode,
    double? maxPositionSizePercentage,
    double? dailyExposureLimit,
    double? maxAllowedVolatility,
    int? maxRebuyCount,
  }) {
    return SettingsModel(
      apiKey: apiKey ?? this.apiKey,
      secretKey: secretKey ?? this.secretKey,
      isBacktestingMode: isBacktestingMode ?? this.isBacktestingMode,
      maxLossPercentage: maxLossPercentage ?? this.maxLossPercentage,
      maxConcurrentTrades: maxConcurrentTrades ?? this.maxConcurrentTrades,
      isDemoMode: isDemoMode ?? this.isDemoMode,
      maxPositionSizePercentage:
          maxPositionSizePercentage ?? this.maxPositionSizePercentage,
      dailyExposureLimit: dailyExposureLimit ?? this.dailyExposureLimit,
      maxAllowedVolatility: maxAllowedVolatility ?? this.maxAllowedVolatility,
      maxRebuyCount: maxRebuyCount ?? this.maxRebuyCount,
    );
  }
}
