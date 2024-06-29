import 'package:cost_averaging_trading_app/core/services/database_service.dart';
import 'package:cost_averaging_trading_app/features/strategy/models/strategy_parameters.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_state.dart';
import 'package:flutter/foundation.dart';

class StrategyRepository {
  final DatabaseService databaseService;

  StrategyRepository({required this.databaseService});

  Future<StrategyParameters> getStrategyParameters() async {
    try {
      final data = await databaseService.query('strategy_parameters');
      if (data.isNotEmpty) {
        return StrategyParameters.fromJson(data.first);
      }
      // Return default parameters if none are saved
      return const StrategyParameters(
        symbol: 'BTCUSDT',
        investmentAmount: 100.0,
        intervalDays: 7,
        targetProfitPercentage: 5.0,
        stopLossPercentage: 3.0,
        purchaseFrequency: 1,
        maxInvestmentSize: 1000.0,
      );
    } catch (e) {
      throw Exception('Failed to get strategy parameters: $e');
    }
  }

  Future<StrategyStateStatus> getStrategyStatus() async {
    try {
      final result = await databaseService.query('strategy_status');
      if (result.isNotEmpty) {
        return StrategyStateStatus.values.firstWhere(
          (e) =>
              e.toString() == 'StrategyStateStatus.${result.first['status']}',
          orElse: () => StrategyStateStatus.inactive,
        );
      }
      return StrategyStateStatus.inactive;
    } catch (e) {
      // Se la tabella non esiste, inserisci uno stato predefinito
      await databaseService.insert('strategy_status', {'status': 'inactive'});
      return StrategyStateStatus.inactive;
    }
  }

  Future<void> saveStrategyStatus(StrategyStateStatus status) async {
    await databaseService.insert(
        'strategy_status', {'status': status.toString().split('.').last});
  }

  Future<List<Map<String, dynamic>>> getStrategyChartData() async {
    // This is a placeholder. In a real application, you'd fetch this data from your database or an API
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

  Future<void> updateStrategyParameters(StrategyParameters parameters) async {
    try {
      await databaseService.insert('strategy_parameters', parameters.toJson());
    } catch (e) {
      throw Exception('Failed to update strategy parameters: $e');
    }
  }
}
