import 'package:cost_averaging_trading_app/core/services/database_service.dart';
import 'package:cost_averaging_trading_app/core/services/trading_service.dart';
import 'package:cost_averaging_trading_app/features/strategy/models/strategy_parameters.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_state.dart';
import 'package:cost_averaging_trading_app/core/models/trade.dart';

class StrategyRepository {
  final DatabaseService databaseService;

  StrategyRepository({
    required this.databaseService,
  });

  Future<void> saveStrategyParameters(StrategyParameters params) async {
    try {
      await databaseService.saveStrategyParameters(params);
    } catch (e) {
      throw Exception('Failed to save strategy parameters: $e');
    }
  }

  Future<void> sellEntirePortfolio(String symbol, double targetProfit, TradingService tradingService) async {
    await tradingService.sellEntirePortfolio(symbol, targetProfit);
  }

  Future<StrategyParameters> getStrategyParameters() async {
    try {
      final params = await databaseService.getStrategyParameters();
      return params ??
          StrategyParameters(
            symbol: 'BTCUSDT',
            investmentAmount: 100.0,
            intervalDays: 7,
            targetProfitPercentage: 5.0,
            stopLossPercentage: 3.0,
            purchaseFrequency: 1,
            maxInvestmentSize: 1000.0,
            useAutoMinTradeAmount: true,
            manualMinTradeAmount: 10.0,
            isVariableInvestmentAmount: false,
            variableInvestmentPercentage: 10.0,
            reinvestProfits: false,
          );
    } catch (e) {
      throw Exception('Failed to get strategy parameters: $e');
    }
  }

  Future<Map<String, dynamic>> getStrategyStatistics() async {
    try {
      final trades = await databaseService.query('trades');

      int totalTrades = trades.length;
      int profitableTrades = trades
          .where((t) => (t['price'] as num) > (t['averageEntryPrice'] as num))
          .length;
      double totalProfit = trades.fold(
          0.0,
          (sum, t) =>
              sum +
              ((t['price'] as num) - (t['averageEntryPrice'] as num)) *
                  (t['amount'] as num));
      double winRate = totalTrades > 0 ? profitableTrades / totalTrades : 0;

      int variableInvestmentTrades =
          trades.where((t) => t['isVariableInvestment'] == 1).length;

      double totalReinvestedProfit = trades
          .where((t) => t['reinvestedProfit'] != null)
          .fold(0.0, (sum, t) => sum + (t['reinvestedProfit'] as num));

      return {
        'totalTrades': totalTrades,
        'profitableTrades': profitableTrades,
        'totalProfit': totalProfit,
        'winRate': winRate,
        'variableInvestmentTrades': variableInvestmentTrades,
        'totalReinvestedProfit': totalReinvestedProfit,
      };
    } catch (e) {
      throw Exception('Failed to get strategy statistics: $e');
    }
  }

  Future<List<CoreTrade>> getRecentTrades(int limit) async {
    try {
      final trades = await databaseService.query('trades',
          orderBy: 'timestamp DESC', limit: limit);

      return trades.map((t) => CoreTrade.fromJson(t)).toList();
    } catch (e) {
      throw Exception('Failed to get recent trades: $e');
    }
  }

  Future<void> saveTradeWithNewFields(CoreTrade trade,
      bool isVariableInvestment, double? reinvestedProfit) async {
    try {
      Map<String, dynamic> tradeData = trade.toJson();
      tradeData['isVariableInvestment'] = isVariableInvestment ? 1 : 0;
      tradeData['reinvestedProfit'] = reinvestedProfit;

      await databaseService.insert('trades', tradeData);
    } catch (e) {
      throw Exception('Failed to save trade with new fields: $e');
    }
  }

  Future<void> updateStrategyStatus(StrategyStateStatus status) async {
    try {
      await databaseService.update(
          'strategy_status', {'status': status.toString().split('.').last});
    } catch (e) {
      throw Exception('Failed to update strategy status: $e');
    }
  }

  Future<StrategyStateStatus> getStrategyStatus() async {
    try {
      final result = await databaseService.query('strategy_status');
      if (result.isNotEmpty) {
        return StrategyStateStatus.values.firstWhere(
          (e) => e.toString().split('.').last == result.first['status'],
          orElse: () => StrategyStateStatus.inactive,
        );
      }
      return StrategyStateStatus.inactive;
    } catch (e) {
      throw Exception('Failed to get strategy status: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getStrategyChartData() async {
    try {
      final trades = await databaseService.query('trades',
          orderBy: 'timestamp DESC', limit: 100);

      return trades.map((trade) {
        return {
          'date':
              DateTime.fromMillisecondsSinceEpoch(trade['timestamp'] as int),
          'value': trade['price'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get strategy chart data: $e');
    }
  }
}
