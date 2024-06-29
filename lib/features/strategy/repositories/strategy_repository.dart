import 'package:cost_averaging_trading_app/core/services/api_service.dart';
import 'package:cost_averaging_trading_app/core/services/database_service.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_state.dart';
import 'package:cost_averaging_trading_app/features/strategy/models/strategy_parameters.dart';
import 'package:cost_averaging_trading_app/core/error/error_handler.dart';

class StrategyRepository {
  final ApiService apiService;
  final DatabaseService databaseService;

  StrategyRepository({required this.apiService, required this.databaseService});

  Future<StrategyParameters> getStrategyParameters() async {
    try {
      final data = await apiService.get('/strategy/parameters');
      return StrategyParameters.fromJson(data);
    } catch (e, stackTrace) {
      ErrorHandler.logError(
          'Failed to get strategy parameters from API', e, stackTrace);
      try {
        final localData = await databaseService.query('strategy_parameters');
        if (localData.isNotEmpty) {
          return StrategyParameters.fromJson(localData.first);
        }
      } catch (e, stackTrace) {
        ErrorHandler.logError(
            'Failed to get strategy parameters from local database',
            e,
            stackTrace);
      }
      return StrategyParameters(
        symbol: 'BTC/USDT',
        investmentAmount: 100.0,
        intervalDays: 7,
        targetProfitPercentage: 5.0,
        stopLossPercentage: 3.0,
        purchaseFrequency: 1,
        maxInvestmentSize: 1000.0,
      );
    }
  }

  Future<void> updateStrategyParameters(StrategyParameters parameters) async {
    try {
      await apiService.post('/strategy/parameters', parameters.toJson());
    } catch (e, stackTrace) {
      ErrorHandler.logError(
          'Failed to update strategy parameters on API', e, stackTrace);
      try {
        await databaseService.insert(
            'strategy_parameters', parameters.toJson());
      } catch (e, stackTrace) {
        ErrorHandler.logError(
            'Failed to save strategy parameters to local database',
            e,
            stackTrace);
        throw Exception('Impossibile aggiornare i parametri della strategia');
      }
    }
  }

  Future<StrategyStateStatus> getStrategyStatus() async {
    try {
      final data = await apiService.get('/strategy/status');
      return StrategyStateStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => StrategyStateStatus.inactive,
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError('Failed to get strategy status', e, stackTrace);
      return StrategyStateStatus.inactive;
    }
  }

  Future<List<Map<String, dynamic>>> getStrategyChartData() async {
    try {
      final data = await apiService.get('/strategy/chart-data');
      return List<Map<String, dynamic>>.from(data);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Failed to get strategy chart data', e, stackTrace);
      return [
        {
          'date': DateTime.now().subtract(const Duration(days: 30)),
          'value': 1000
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 20)),
          'value': 1100
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 10)),
          'value': 1050
        },
        {'date': DateTime.now(), 'value': 1200},
      ];
    }
  }

  Future<void> startStrategy() async {
    try {
      await apiService.post('/strategy/start', {});
    } catch (e, stackTrace) {
      ErrorHandler.logError('Failed to start strategy', e, stackTrace);
      throw Exception('Impossibile avviare la strategia');
    }
  }

  Future<void> stopStrategy() async {
    try {
      await apiService.post('/strategy/stop', {});
    } catch (e, stackTrace) {
      ErrorHandler.logError('Failed to stop strategy', e, stackTrace);
      throw Exception('Impossibile fermare la strategia');
    }
  }
}
