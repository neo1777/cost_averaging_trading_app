import 'package:cost_averaging_trading_app/core/models/portfolio.dart';
import 'package:cost_averaging_trading_app/core/services/api_service.dart';
import 'package:cost_averaging_trading_app/core/services/database_service.dart';

class PortfolioRepository {
  final ApiService apiService;
  final DatabaseService databaseService;

  PortfolioRepository(
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
          final price = await apiService.getCurrentPrice('${entry.key}USDT');
          totalValue += entry.value * price;
        } else {
          totalValue += entry.value;
        }
      }

      // Salva il valore del portfolio nel database
      await databaseService.savePortfolioValue(DateTime.now(), totalValue);

      return Portfolio(
        id: accountInfo['accountType'],
        assets: assets,
        totalValue: totalValue,
      );
    } catch (e) {
      // Se fallisce l'API, restituisci un portfolio vuoto
      return Portfolio(
        id: 'default',
        assets: {},
        totalValue: 0,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getPerformanceData() async {
    try {
      final historicalData = await databaseService.query(
        'portfolio_value',
        orderBy: 'timestamp ASC',
        limit: 30,
      );

      if (historicalData.isEmpty) {
        // Se non ci sono dati storici, restituisci un singolo punto dati con il valore corrente
        final currentPortfolio = await getPortfolio();
        return [
          {
            'date': DateTime.now(),
            'value': currentPortfolio.totalValue,
          }
        ];
      }

      return historicalData
          .map((data) => {
                'date': DateTime.fromMillisecondsSinceEpoch(
                    data['timestamp'] as int),
                'value': data['value'] as double,
              })
          .toList();
    } catch (e) {
      // In caso di errore, restituisci un singolo punto dati con valore zero
      return [
        {
          'date': DateTime.now(),
          'value': 0.0,
        }
      ];
    }
  }

  Future<double> getDailyChange() async {
    try {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final today = DateTime.now();
      final yesterdayValue =
          await databaseService.getPortfolioValueForDate(yesterday);
      final todayValue = await databaseService.getPortfolioValueForDate(today);
      return (todayValue - yesterdayValue) / yesterdayValue * 100;
    } catch (e) {
      return 0.0; // Restituisci 0% di cambiamento se non ci sono dati sufficienti
    }
  }

  Future<double> getWeeklyChange() async {
    try {
      final lastWeek = DateTime.now().subtract(const Duration(days: 7));
      final today = DateTime.now();
      final lastWeekValue =
          await databaseService.getPortfolioValueForDate(lastWeek);
      final todayValue = await databaseService.getPortfolioValueForDate(today);
      return (todayValue - lastWeekValue) / lastWeekValue * 100;
    } catch (e) {
      return 0.0; // Restituisci 0% di cambiamento se non ci sono dati sufficienti
    }
  }
}
