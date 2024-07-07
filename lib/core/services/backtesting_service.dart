import 'dart:math';
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
    void Function(double progress,
            List<Map<String, dynamic>> currentInvestmentOverTime)
        onProgress,
  ) async {
    try {
      List<HistoricalDataPoint> historicalData =
          await _fetchHistoricalData(symbol, startDate, endDate);

      List<CoreTrade> trades = [];
      double portfolioValue = parameters.investmentAmount;
      double btcAmount = 0;
      double averageEntryPrice = 0;
      int daysSinceLastPurchase = 0;

      double highestPortfolioValue = portfolioValue;
      double lowestPortfolioValue = portfolioValue;
      List<double> dailyReturns = [];
      double previousPortfolioValue = portfolioValue;
      List<Map<String, dynamic>> investmentOverTime = [];

      for (int i = 0; i < historicalData.length; i++) {
        HistoricalDataPoint currentData = historicalData[i];
        daysSinceLastPurchase++;

        double currentPortfolioValue =
            portfolioValue + (btcAmount * currentData.close);

        if (i > 0) {
          double dailyReturn =
              (currentPortfolioValue - previousPortfolioValue) /
                  previousPortfolioValue;
          dailyReturns.add(dailyReturn);
        }
        previousPortfolioValue = currentPortfolioValue;

        highestPortfolioValue =
            max(highestPortfolioValue, currentPortfolioValue);
        lowestPortfolioValue = min(lowestPortfolioValue, currentPortfolioValue);

        investmentOverTime.add({
          'date': currentData.timestamp,
          'value': currentPortfolioValue,
        });

        if (btcAmount > 0 &&
            currentData.close <=
                averageEntryPrice * (1 - parameters.stopLossPercentage / 100)) {
          trades.add(CoreTrade(
            id: (i + 2000000).toString(),
            symbol: symbol,
            amount: btcAmount,
            price: currentData.close,
            timestamp: currentData.timestamp,
            type: CoreTradeType.sell,
          ));

          portfolioValue += btcAmount * currentData.close;
          btcAmount = 0;
          averageEntryPrice = 0;
        }

        if (daysSinceLastPurchase >= parameters.purchaseFrequency) {
          double investmentAmount = parameters.investmentAmount;
          if (parameters.isVariableInvestmentAmount) {
            double variationPercentage =
                (parameters.variableInvestmentPercentage / 100);
            double randomFactor =
                1 + (Random().nextDouble() * 2 - 1) * variationPercentage;
            investmentAmount *= randomFactor;
          }

          double buyAmount = investmentAmount / currentData.close;
          if (parameters.useAutoMinTradeAmount) {
            double minTradeAmount = 0.00001;
            buyAmount =
                buyAmount.clamp(minTradeAmount, parameters.maxInvestmentSize);
          } else {
            buyAmount = buyAmount.clamp(
                parameters.manualMinTradeAmount, parameters.maxInvestmentSize);
          }

          if (portfolioValue >= buyAmount * currentData.close) {
            btcAmount += buyAmount;
            portfolioValue -= buyAmount * currentData.close;

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
        }

        if (btcAmount > 0 &&
            currentData.close >=
                averageEntryPrice *
                    (1 + parameters.targetProfitPercentage / 100)) {
          trades.add(CoreTrade(
            id: (i + 1000000).toString(),
            symbol: symbol,
            amount: btcAmount,
            price: currentData.close,
            timestamp: currentData.timestamp,
            type: CoreTradeType.sell,
          ));

          double sellValue = btcAmount * currentData.close;
          portfolioValue += sellValue;

          if (parameters.reinvestProfits) {
            double profit = sellValue - (btcAmount * averageEntryPrice);
            double reinvestAmount = profit / currentData.close;
            btcAmount = reinvestAmount;
            averageEntryPrice = currentData.close;
          } else {
            btcAmount = 0;
            averageEntryPrice = 0;
          }
        }
        if (i % 10 == 0) {
          // Emetti un aggiornamento ogni 10 giorni
          onProgress(i / historicalData.length, List.from(investmentOverTime));
        }
      }

      double finalPortfolioValue =
          portfolioValue + (btcAmount * historicalData.last.close);
      double totalProfit = finalPortfolioValue - parameters.investmentAmount;
      double totalReturn = totalProfit / parameters.investmentAmount;
      double maxDrawdown = (highestPortfolioValue - lowestPortfolioValue) /
          highestPortfolioValue;

      int profitableTrades = trades
          .where((t) =>
              t.type == CoreTradeType.sell && t.price > averageEntryPrice)
          .length;
      double winRate = profitableTrades /
          trades.where((t) => t.type == CoreTradeType.sell).length;

      double averageDailyReturn =
          dailyReturns.reduce((a, b) => a + b) / dailyReturns.length;
      double stdDailyReturn = sqrt(dailyReturns
              .map((r) => pow(r - averageDailyReturn, 2))
              .reduce((a, b) => a + b) /
          dailyReturns.length);
      double sharpeRatio = sqrt(252) * averageDailyReturn / stdDailyReturn;

      double sortinoRatio = calculateSortinoRatio(dailyReturns,
          0.02 / 252); // Assumendo un tasso risk-free del 2% annuo
      int totalTrades = trades.length;
      double averageTradeProfit = totalProfit / totalTrades;

      return BacktestResult(
        trades: trades,
        performance: BacktestPerformance(
          totalProfit: totalProfit,
          totalReturn: totalReturn,
          maxDrawdown: maxDrawdown,
          winRate: winRate,
          sharpeRatio: sharpeRatio,
          sortinoRatio: sortinoRatio,
          totalTrades: totalTrades,
          averageTradeProfit: averageTradeProfit,
        ),
        investmentOverTime: investmentOverTime,
      );
    } catch (e) {
      print('Error during backtesting: $e');
      rethrow;
    }
  }

  Future<double> getMinimumTradeAmount(String symbol) async {
    try {
      return await apiService.getMinimumTradeAmount(symbol);
    } catch (e) {
      print('Error getting minimum trade amount: $e');
      return 0.00001; // Valore di fallback
    }
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
}

double calculateSortinoRatio(List<double> dailyReturns, double riskFreeRate) {
  double averageReturn =
      dailyReturns.reduce((a, b) => a + b) / dailyReturns.length;
  List<double> negativeReturns = dailyReturns.where((r) => r < 0).toList();
  double downsideDeviation = sqrt(negativeReturns
          .map((r) => pow(r - riskFreeRate, 2))
          .reduce((a, b) => a + b) /
      negativeReturns.length);
  return sqrt(252) * (averageReturn - riskFreeRate) / downsideDeviation;
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
  final List<Map<String, dynamic>> investmentOverTime;

  BacktestResult({
    required this.trades,
    required this.performance,
    required this.investmentOverTime,
  });
}

class BacktestPerformance {
  final double totalProfit;
  final double totalReturn;
  final double maxDrawdown;
  final double winRate;
  final double sharpeRatio;
  final double sortinoRatio; // Nuovo
  final int totalTrades; // Nuovo
  final double averageTradeProfit; // Nuovo

  BacktestPerformance({
    required this.totalProfit,
    required this.totalReturn,
    required this.maxDrawdown,
    required this.winRate,
    required this.sharpeRatio,
    required this.sortinoRatio,
    required this.totalTrades,
    required this.averageTradeProfit,
  });
}
