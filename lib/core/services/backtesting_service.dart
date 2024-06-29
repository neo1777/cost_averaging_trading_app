import 'dart:math';
import 'package:cost_averaging_trading_app/core/models/trade.dart';
import 'package:cost_averaging_trading_app/core/services/api_service.dart';
import 'package:cost_averaging_trading_app/features/strategy/models/strategy_parameters.dart';

class BacktestingService {
  final ApiService apiService;

  BacktestingService(this.apiService);

  Future<BacktestResult> runBacktest(String symbol, DateTime startDate,
      DateTime endDate, StrategyParameters strategyParameters) async {
    final historicalData = await _getHistoricalData(symbol, startDate, endDate);
    final trades = _simulateTrading(historicalData, strategyParameters);
    final performance = _calculatePerformance(trades, historicalData);
    return BacktestResult(trades: trades, performance: performance);
  }

  Future<List<HistoricalDataPoint>> _getHistoricalData(
      String symbol, DateTime startDate, DateTime endDate) async {
    final response = await apiService.getKlines(
      symbol: symbol,
      interval: '1d',
      startTime: startDate.millisecondsSinceEpoch,
      endTime: endDate.millisecondsSinceEpoch,
    );

    return response
        .map((data) => HistoricalDataPoint(
              timestamp: DateTime.fromMillisecondsSinceEpoch(data['0']),
              open: double.parse(data['1']),
              high: double.parse(data['2']),
              low: double.parse(data['3']),
              close: double.parse(data['4']),
              volume: double.parse(data['5']),
            ))
        .toList();
  }

  List<CoreTrade> _simulateTrading(
      List<HistoricalDataPoint> historicalData, StrategyParameters params) {
    List<CoreTrade> trades = [];
    double portfolioValue = params.investmentAmount;
    double btcAmount = 0;

    for (int i = 0; i < historicalData.length; i++) {
      final currentPrice = historicalData[i].close;

      // Implementa la logica di trading qui
      if (i % params.intervalDays == 0) {
        // Esegui un acquisto
        double amountToSpend = min(params.investmentAmount, portfolioValue);
        double btcToBuy = amountToSpend / currentPrice;

        trades.add(CoreTrade(
          id: i.toString(),
          symbol: params.symbol,
          amount: btcToBuy,
          price: currentPrice,
          timestamp: historicalData[i].timestamp,
          type: CoreTradeType.buy,
        ));

        portfolioValue -= amountToSpend;
        btcAmount += btcToBuy;
      }

      // Controlla se è necessario vendere
      if (currentPrice >= params.targetProfitPercentage * trades.last.price) {
        trades.add(CoreTrade(
          id: (i + 1000000)
              .toString(), // Per evitare conflitti con gli ID di acquisto
          symbol: params.symbol,
          amount: btcAmount,
          price: currentPrice,
          timestamp: historicalData[i].timestamp,
          type: CoreTradeType.sell,
        ));

        portfolioValue += btcAmount * currentPrice;
        btcAmount = 0;
      }
    }

    return trades;
  }

  BacktestPerformance _calculatePerformance(
      List<CoreTrade> trades, List<HistoricalDataPoint> historicalData) {
    double totalProfit = 0;
    int winningTrades = 0;
    double maxDrawdown = 0;
    double peakValue = 0;
    double currentDrawdown = 0;

    for (int i = 0; i < trades.length; i++) {
      if (trades[i].type == CoreTradeType.sell) {
        double buyPrice = trades[i - 1].price;
        double sellPrice = trades[i].price;
        double profit = (sellPrice - buyPrice) * trades[i].amount;

        totalProfit += profit;
        if (profit > 0) winningTrades++;

        if (totalProfit > peakValue) {
          peakValue = totalProfit;
          currentDrawdown = 0;
        } else {
          currentDrawdown = peakValue - totalProfit;
          if (currentDrawdown > maxDrawdown) {
            maxDrawdown = currentDrawdown;
          }
        }
      }
    }

    double winRate = trades.isEmpty ? 0 : winningTrades / (trades.length / 2);
    double sharpeRatio = _calculateSharpeRatio(trades, historicalData);

    return BacktestPerformance(
      totalProfit: totalProfit,
      winRate: winRate,
      maxDrawdown: maxDrawdown,
      sharpeRatio: sharpeRatio,
    );
  }

  double _calculateSharpeRatio(
      List<CoreTrade> trades, List<HistoricalDataPoint> historicalData) {
    List<double> returns = [];
    for (int i = 1; i < trades.length; i += 2) {
      double buyPrice = trades[i - 1].price;
      double sellPrice = trades[i].price;
      returns.add((sellPrice - buyPrice) / buyPrice);
    }

    double averageReturn = returns.reduce((a, b) => a + b) / returns.length;
    double standardDeviation = sqrt(
        returns.map((r) => pow(r - averageReturn, 2)).reduce((a, b) => a + b) /
            returns.length);

    // Assumiamo un tasso di interesse privo di rischio dello 0% per semplicità
    return averageReturn /
        standardDeviation *
        sqrt(
            252); // 252 è il numero approssimativo di giorni di trading in un anno
  }
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
