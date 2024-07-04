import 'dart:math' as math;
import 'package:cost_averaging_trading_app/core/models/trade.dart';
import 'package:cost_averaging_trading_app/core/services/api_service.dart';
import 'package:cost_averaging_trading_app/features/strategy/models/strategy_parameters.dart';

class BacktestingService {
  final ApiService apiService;

  BacktestingService(this.apiService);

  Future<BacktestResult> runBacktest(
    String symbol,
    DateTime startDate,
    DateTime endDate,
    StrategyParameters parameters,
  ) async {
    List<HistoricalDataPoint> historicalData =
        await _fetchHistoricalData(symbol, startDate, endDate);

    List<CoreTrade> trades = [];
    double portfolioValue = parameters.investmentAmount;
    double btcAmount = 0;
    double averageEntryPrice = 0;
    int daysSinceLastPurchase = 0;

    for (int i = 0; i < historicalData.length; i++) {
      HistoricalDataPoint currentData = historicalData[i];
      daysSinceLastPurchase++;

      // Check for stop loss
      if (btcAmount > 0 &&
          currentData.close <=
              averageEntryPrice * (1 - parameters.stopLossPercentage / 100)) {
        double sellAmount = btcAmount;
        double sellValue = sellAmount * currentData.close;
        portfolioValue += sellValue;

        trades.add(CoreTrade(
          id: (i + 2000000).toString(),
          symbol: symbol,
          amount: sellAmount,
          price: currentData.close,
          timestamp: currentData.timestamp,
          type: CoreTradeType.sell,
        ));

        btcAmount = 0;
        averageEntryPrice = 0;
      }

      // Simulate buy
      if (daysSinceLastPurchase >= parameters.purchaseFrequency) {
        double buyAmount = parameters.investmentAmount / currentData.close;
        btcAmount += buyAmount;
        portfolioValue -= parameters.investmentAmount;

        // Update average entry price
        averageEntryPrice = (averageEntryPrice * (btcAmount - buyAmount) +
                currentData.close * buyAmount) /
            btcAmount;

        trades.add(CoreTrade(
          id: i.toString(),
          symbol: symbol,
          amount: buyAmount,
          price: currentData.close,
          timestamp: currentData.timestamp,
          type: CoreTradeType.buy,
        ));

        daysSinceLastPurchase = 0;
      }

      // Check for take profit
      if (btcAmount > 0 &&
          currentData.close >=
              averageEntryPrice *
                  (1 + parameters.targetProfitPercentage / 100)) {
        double sellAmount = btcAmount;
        double sellValue = sellAmount * currentData.close;
        portfolioValue += sellValue;

        trades.add(CoreTrade(
          id: (i + 1000000).toString(),
          symbol: symbol,
          amount: sellAmount,
          price: currentData.close,
          timestamp: currentData.timestamp,
          type: CoreTradeType.sell,
        ));

        btcAmount = 0;
        averageEntryPrice = 0;
      }
    }

    // Calculate performance metrics
    double totalInvestment = parameters.investmentAmount *
        (historicalData.length / parameters.purchaseFrequency);
    double finalPortfolioValue =
        portfolioValue + (btcAmount * historicalData.last.close);
    double totalProfit = finalPortfolioValue - totalInvestment;
    double winRate = trades
            .where((t) =>
                t.type == CoreTradeType.sell && t.price > averageEntryPrice)
            .length /
        trades.where((t) => t.type == CoreTradeType.sell).length;
    double maxDrawdown = _calculateMaxDrawdown(trades, historicalData);
    double sharpeRatio = _calculateSharpeRatio(trades, historicalData);

    return BacktestResult(
      trades: trades,
      performance: BacktestPerformance(
        totalProfit: totalProfit,
        winRate: winRate,
        maxDrawdown: maxDrawdown,
        sharpeRatio: sharpeRatio,
      ),
    );
  }

  Future<List<HistoricalDataPoint>> _fetchHistoricalData(
      String symbol, DateTime startDate, DateTime endDate) async {
    final klines = await apiService.getKlines(
      symbol: symbol,
      interval: '1d',
      startTime: startDate.millisecondsSinceEpoch,
      endTime: endDate.millisecondsSinceEpoch,
    );

    return klines
        .map((kline) => HistoricalDataPoint(
              timestamp: DateTime.fromMillisecondsSinceEpoch(kline[0]),
              open: double.parse(kline[1]),
              high: double.parse(kline[2]),
              low: double.parse(kline[3]),
              close: double.parse(kline[4]),
              volume: double.parse(kline[5]),
            ))
        .toList();
  }

  double _calculateMaxDrawdown(
      List<CoreTrade> trades, List<HistoricalDataPoint> historicalData) {
    double maxDrawdown = 0;
    double peak = 0;
    double currentValue = 0;

    for (var data in historicalData) {
      currentValue =
          trades
              .where((t) => t.timestamp.isBefore(data.timestamp))
              .fold(
                  0,
                  (sum, trade) =>
                      sum +
                      (trade.type == CoreTradeType.buy
                          ? -trade.amount * trade.price
                          : trade.amount * trade.price));

      if (currentValue > peak) {
        peak = currentValue;
      }

      double drawdown = (peak - currentValue) / peak;
      if (drawdown > maxDrawdown) {
        maxDrawdown = drawdown;
      }
    }

    return maxDrawdown;
  }

  double _calculateSharpeRatio(
      List<CoreTrade> trades, List<HistoricalDataPoint> historicalData) {
    List<double> returns = [];
    double previousValue = 0;

    for (var data in historicalData) {
      double currentValue = trades
          .where((t) => t.timestamp.isBefore(data.timestamp))
          .fold(
              0,
              (sum, trade) =>
                  sum +
                  (trade.type == CoreTradeType.buy
                      ? -trade.amount * trade.price
                      : trade.amount * trade.price));

      if (previousValue != 0) {
        returns.add((currentValue - previousValue) / previousValue);
      }

      previousValue = currentValue;
    }

    double averageReturn = returns.reduce((a, b) => a + b) / returns.length;
    double stdDev = _calculateStandardDeviation(returns);

    // Assuming risk-free rate is 0 for simplicity
    return averageReturn / stdDev * math.sqrt(252); // Annualized Sharpe Ratio
  }

  double _calculateStandardDeviation(List<double> values) {
    double mean = values.reduce((a, b) => a + b) / values.length;
    num squaredDifferencesSum = values
        .map((value) => math.pow(value - mean, 2))
        .reduce((a, b) => a + b);
    return math.sqrt(squaredDifferencesSum / (values.length - 1));
  }
}

class HistoricalDataPoint {
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  HistoricalDataPoint({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });
}

class BacktestResult {
  final List<CoreTrade> trades;
  final BacktestPerformance performance;

  BacktestResult({required this.trades, required this.performance});
}

class BacktestPerformance {
  final double totalProfit;
  final double winRate;
  final double maxDrawdown;
  final double sharpeRatio;

  BacktestPerformance({
    required this.totalProfit,
    required this.winRate,
    required this.maxDrawdown,
    required this.sharpeRatio,
  });
}
