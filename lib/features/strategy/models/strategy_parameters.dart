import 'package:equatable/equatable.dart';

class StrategyParameters extends Equatable {
  final String symbol;
  final double investmentAmount;
  final int intervalDays;
  final double targetProfitPercentage;
  final double stopLossPercentage;
  final int purchaseFrequency;
  final double maxInvestmentSize;
  // Nuovi campi aggiunti
  final bool useAutoMinTradeAmount;
  final double manualMinTradeAmount;
  final bool isVariableInvestmentAmount;
  final double variableInvestmentPercentage;
  final bool reinvestProfits;

  StrategyParameters({
    required this.symbol,
    required this.investmentAmount,
    required this.intervalDays,
    required this.targetProfitPercentage,
    required this.stopLossPercentage,
    required this.purchaseFrequency,
    required this.maxInvestmentSize,
    // Nuovi campi aggiunti al costruttore
    this.useAutoMinTradeAmount = true,
    this.manualMinTradeAmount = 0.0,
    this.isVariableInvestmentAmount = false,
    this.variableInvestmentPercentage = 0.0,
    this.reinvestProfits = false,
  }) {
    assert(investmentAmount > 0, 'Investment amount must be positive');
    assert(intervalDays > 0, 'Interval days must be positive');
    assert(targetProfitPercentage > 0 && targetProfitPercentage <= 100,
        'Target profit must be between 0 and 100');
    assert(stopLossPercentage > 0 && stopLossPercentage <= 100,
        'Stop loss must be between 0 and 100');
    assert(purchaseFrequency > 0, 'Purchase frequency must be positive');
    assert(maxInvestmentSize > 0, 'Max investment size must be positive');
    // Nuove asserzioni per i nuovi campi
    assert(manualMinTradeAmount >= 0,
        'Manual min trade amount must be non-negative');
    assert(
        variableInvestmentPercentage >= 0 &&
            variableInvestmentPercentage <= 100,
        'Variable investment percentage must be between 0 and 100');
  }

  @override
  List<Object?> get props => [
        symbol,
        investmentAmount,
        intervalDays,
        targetProfitPercentage,
        stopLossPercentage,
        purchaseFrequency,
        maxInvestmentSize,
        // Nuovi campi aggiunti alla lista props
        useAutoMinTradeAmount,
        manualMinTradeAmount,
        isVariableInvestmentAmount,
        variableInvestmentPercentage,
        reinvestProfits,
      ];

  StrategyParameters copyWith({
    String? symbol,
    double? investmentAmount,
    int? intervalDays,
    double? targetProfitPercentage,
    double? stopLossPercentage,
    int? purchaseFrequency,
    double? maxInvestmentSize,
    // Nuovi campi aggiunti al metodo copyWith
    bool? useAutoMinTradeAmount,
    double? manualMinTradeAmount,
    bool? isVariableInvestmentAmount,
    double? variableInvestmentPercentage,
    bool? reinvestProfits,
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
      // Nuovi campi aggiunti al metodo copyWith
      useAutoMinTradeAmount:
          useAutoMinTradeAmount ?? this.useAutoMinTradeAmount,
      manualMinTradeAmount: manualMinTradeAmount ?? this.manualMinTradeAmount,
      isVariableInvestmentAmount:
          isVariableInvestmentAmount ?? this.isVariableInvestmentAmount,
      variableInvestmentPercentage:
          variableInvestmentPercentage ?? this.variableInvestmentPercentage,
      reinvestProfits: reinvestProfits ?? this.reinvestProfits,
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
      // Nuovi campi aggiunti al metodo fromJson
      useAutoMinTradeAmount: json['useAutoMinTradeAmount'] ?? true,
      manualMinTradeAmount: json['manualMinTradeAmount'] ?? 0.0,
      isVariableInvestmentAmount: json['isVariableInvestmentAmount'] ?? false,
      variableInvestmentPercentage: json['variableInvestmentPercentage'] ?? 0.0,
      reinvestProfits: json['reinvestProfits'] ?? false,
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
      // Nuovi campi aggiunti al metodo toJson
      'useAutoMinTradeAmount': useAutoMinTradeAmount,
      'manualMinTradeAmount': manualMinTradeAmount,
      'isVariableInvestmentAmount': isVariableInvestmentAmount,
      'variableInvestmentPercentage': variableInvestmentPercentage,
      'reinvestProfits': reinvestProfits,
    };
  }
}
