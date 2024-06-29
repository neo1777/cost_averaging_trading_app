import 'package:equatable/equatable.dart';

class StrategyParameters extends Equatable {
  final String symbol;
  final double investmentAmount;
  final int intervalDays;
  final double targetProfitPercentage;
  final double stopLossPercentage;
  final int purchaseFrequency;
  final double maxInvestmentSize;

  const StrategyParameters({
    required this.symbol,
    required this.investmentAmount,
    required this.intervalDays,
    required this.targetProfitPercentage,
    required this.stopLossPercentage,
    required this.purchaseFrequency,
    required this.maxInvestmentSize,
  });

  @override
  List<Object> get props => [
        symbol,
        investmentAmount,
        intervalDays,
        targetProfitPercentage,
        stopLossPercentage,
        purchaseFrequency,
        maxInvestmentSize,
      ];

  StrategyParameters copyWith({
    String? symbol,
    double? investmentAmount,
    int? intervalDays,
    double? targetProfitPercentage,
    double? stopLossPercentage,
    int? purchaseFrequency,
    double? maxInvestmentSize,
  }) {
    return StrategyParameters(
      symbol: symbol ?? this.symbol,
      investmentAmount: investmentAmount ?? this.investmentAmount,
      intervalDays: intervalDays ?? this.intervalDays,
      targetProfitPercentage:
          targetProfitPercentage ?? this.targetProfitPercentage,
      stopLossPercentage: stopLossPercentage ?? this.stopLossPercentage,
      purchaseFrequency: purchaseFrequency ?? this.purchaseFrequency,
      maxInvestmentSize: maxInvestmentSize ?? this.maxInvestmentSize,
    );
  }

  factory StrategyParameters.fromJson(Map<String, dynamic> json) {
    return StrategyParameters(
      symbol: json['symbol'],
      investmentAmount: json['investmentAmount'],
      intervalDays: json['intervalDays'],
      targetProfitPercentage: json['targetProfitPercentage'],
      stopLossPercentage: json['stopLossPercentage'],
      purchaseFrequency: json['purchaseFrequency'],
      maxInvestmentSize: json['maxInvestmentSize'],
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
