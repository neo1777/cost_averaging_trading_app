class StrategyModel {
  final double initialCapital;
  final double riskPercentage;
  final double minProfitTarget;
  final double maxLossPercentage;
  final int maxTrades;
  final bool isActive;

  StrategyModel({
    required this.initialCapital,
    required this.riskPercentage,
    required this.minProfitTarget,
    required this.maxLossPercentage,
    required this.maxTrades,
    required this.isActive,
  });

  StrategyModel copyWith({
    double? initialCapital,
    double? riskPercentage,
    double? minProfitTarget,
    double? maxLossPercentage,
    int? maxTrades,
    bool? isActive,
  }) {
    return StrategyModel(
      initialCapital: initialCapital ?? this.initialCapital,
      riskPercentage: riskPercentage ?? this.riskPercentage,
      minProfitTarget: minProfitTarget ?? this.minProfitTarget,
      maxLossPercentage: maxLossPercentage ?? this.maxLossPercentage,
      maxTrades: maxTrades ?? this.maxTrades,
      isActive: isActive ?? this.isActive,
    );
  }
}
