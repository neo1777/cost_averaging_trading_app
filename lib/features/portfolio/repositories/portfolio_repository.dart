import 'package:cost_averaging_trading_app/core/models/portfolio.dart';
import 'package:cost_averaging_trading_app/core/models/trade.dart';
import 'package:cost_averaging_trading_app/core/services/api_service.dart';
import 'package:cost_averaging_trading_app/core/services/database_service.dart';

class PortfolioRepository {
  final ApiService apiService;
  final DatabaseService databaseService;

  PortfolioRepository(
      {required this.apiService, required this.databaseService});

  Future<Portfolio> getPortfolio() async {
    // Implementa la logica per ottenere il portfolio
    // Usa apiService o databaseService a seconda delle necessità
    // Per ora, restituiamo dati di esempio
    return const Portfolio(
      id: '1',
      assets: {'BTC': 0.5, 'ETH': 2.0, 'USDT': 1000.0},
      totalValue: 10000.0,
    );
  }

  Future<List<Map<String, dynamic>>> getPerformanceData() async {
    // Implementa la logica per ottenere i dati di performance
    // Usa apiService o databaseService a seconda delle necessità
    // Per ora, restituiamo dati di esempio
    return [
      {
        'date': DateTime.now().subtract(const Duration(days: 30)),
        'value': 9000.0
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 20)),
        'value': 9500.0
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 10)),
        'value': 9800.0
      },
      {'date': DateTime.now(), 'value': 10000.0},
    ];
  }

  Future<double> getDailyChange() async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final today = DateTime.now();
    final yesterdayValue =
        await databaseService.getPortfolioValueForDate(yesterday);
    final todayValue = await databaseService.getPortfolioValueForDate(today);
    return (todayValue - yesterdayValue) / yesterdayValue * 100;
  }

  Future<double> getWeeklyChange() async {
    final lastWeek = DateTime.now().subtract(const Duration(days: 7));
    final today = DateTime.now();
    final lastWeekValue =
        await databaseService.getPortfolioValueForDate(lastWeek);
    final todayValue = await databaseService.getPortfolioValueForDate(today);
    return (todayValue - lastWeekValue) / lastWeekValue * 100;
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
}
