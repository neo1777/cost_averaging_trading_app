// lib/features/portfolio/repositories/portfolio_repository.dart

import 'package:cost_averaging_trading_app/core/models/portfolio.dart';
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
}
