enum StrategyExecutionResult {
  success,
  tradeNotAllowed,
  insufficientTime,
  error;

  bool get isSuccess => this == StrategyExecutionResult.success;
  bool get isTradeNotAllowed => this == StrategyExecutionResult.tradeNotAllowed;
  bool get isInsufficientTime => this == StrategyExecutionResult.insufficientTime;
  bool get isError => this == StrategyExecutionResult.error;

  String get message {
    switch (this) {
      case StrategyExecutionResult.success:
        return 'Strategy executed successfully';
      case StrategyExecutionResult.tradeNotAllowed:
        return 'Trade not allowed due to risk limits';
      case StrategyExecutionResult.insufficientTime:
        return 'Insufficient time since last trade';
      case StrategyExecutionResult.error:
        return 'An error occurred during strategy execution';
    }
  }
}