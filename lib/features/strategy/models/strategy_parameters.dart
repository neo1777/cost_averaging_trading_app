// lib/features/strategy/models/strategy_parameters.dart

class StrategyParameters {
  final String symbol;
  final double investmentAmount;
  final int intervalDays;
  final double targetProfitPercentage;
  final double stopLossPercentage;
  final int purchaseFrequency; // Nuovo parametro
  final double maxInvestmentSize; // Nuovo parametro

  StrategyParameters({
    required this.symbol,
    required this.investmentAmount,
    required this.intervalDays,
    required this.targetProfitPercentage,
    required this.stopLossPercentage,
    required this.purchaseFrequency,
    required this.maxInvestmentSize,
  });

  factory StrategyParameters.fromJson(Map<String, dynamic> json) {
    return StrategyParameters(
      symbol: json['symbol'],
      investmentAmount: json['investmentAmount'].toDouble(),
      intervalDays: json['intervalDays'],
      targetProfitPercentage: json['targetProfitPercentage'].toDouble(),
      stopLossPercentage: json['stopLossPercentage'].toDouble(),
      purchaseFrequency: json['purchaseFrequency'],
      maxInvestmentSize: json['maxInvestmentSize'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'investmentAmount': investmentAmount,
      'intervalDays': intervalDays,
      'targetProfitPercentage': targetProfitPercentage,
      'stopLossPercentage': stopLossPercentage,
      'purchaseFrequency': purchaseFrequency,
      'maxInvestmentSize': maxInvestmentSize,
    };
  }
}
