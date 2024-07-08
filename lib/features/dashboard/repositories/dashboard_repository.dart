import 'package:cost_averaging_trading_app/core/models/portfolio.dart';
import 'package:cost_averaging_trading_app/core/models/trade.dart';
import 'package:cost_averaging_trading_app/core/services/api_service.dart';
import 'package:cost_averaging_trading_app/core/services/database_service.dart';

class DashboardRepository {
  final ApiService apiService;
  final DatabaseService databaseService;

  DashboardRepository(
      {required this.apiService, required this.databaseService});

  Future<Portfolio> getPortfolio() async {
    try {
      final accountInfo = await apiService.getAccountInfo();
      final balances = accountInfo['balances'] as List;
      final assets = Map<String, double>.fromEntries(
        balances.where((b) => double.parse(b['free']) > 0).map(
              (b) => MapEntry(b['asset'], double.parse(b['free'])),
            ),
      );

      double totalValue = 0;
      for (var entry in assets.entries) {
        if (entry.key != 'USDT') {
          try {
            final price = await apiService.getCurrentPrice('${entry.key}USDT');
            if (price > 0) {
              totalValue += entry.value * price;
            }
          } catch (e) {
            throw Exception('No local portfolio data available');
          }
        } else {
          totalValue += entry.value;
        }
      }

      return Portfolio(
        id: accountInfo['accountType'],
        assets: assets,
        totalValue: totalValue,
      );
    } catch (e) {
      return _getLocalPortfolio();
    }
  }

  Future<Portfolio> _getLocalPortfolio() async {
    final localData = await databaseService.query('portfolio');
    if (localData.isNotEmpty) {
      return Portfolio.fromJson(localData.first);
    }
    return const Portfolio(
        id: 'local', assets: {}, totalValue: 0); // Return an empty portfolio
  }

  Future<List<CoreTrade>> getRecentTrades() async {
    try {
      final trades =
          await apiService.getMyTrades(symbol: 'BTCUSDT', limit: 100);
      return trades.map((trade) => CoreTrade.fromJson(trade)).toList();
    } catch (e) {
      return _getLocalTrades();
    }
  }

  Future<List<CoreTrade>> _getLocalTrades() async {
    final localData = await databaseService.query('trades');
    return localData.map((trade) => CoreTrade.fromJson(trade)).toList();
  }

  Future<List<Map<String, dynamic>>> getPerformanceData() async {
    try {
      final klines = await apiService.getKlines(
        symbol: 'BTCUSDT',
        interval: '1d',
        limit: 30,
      );
      return klines
          .map((kline) => {
                'date': DateTime.fromMillisecondsSinceEpoch(kline[0]),
                'value': double.parse(kline[4]), // Closing price
              })
          .toList();
    } catch (e) {
      // Fallback to example data if API call fails
      return [
        {
          'date': DateTime.now().subtract(const Duration(days: 30)),
          'value': 30000
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 20)),
          'value': 32000
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 10)),
          'value': 31000
        },
        {'date': DateTime.now(), 'value': 33000},
      ];
    }
  }
}
