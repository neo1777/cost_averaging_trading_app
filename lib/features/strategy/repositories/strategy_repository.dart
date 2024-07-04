import 'package:cost_averaging_trading_app/core/models/strategy_execution_result.dart';
import 'package:cost_averaging_trading_app/core/services/database_service.dart';
import 'package:cost_averaging_trading_app/features/strategy/models/strategy_parameters.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_state.dart';
import 'package:cost_averaging_trading_app/core/services/trading_service.dart';

class StrategyRepository {
  final DatabaseService databaseService;
  final TradingService tradingService;

  StrategyRepository(
      {required this.databaseService, required this.tradingService});

  Future<void> initializeStrategyStatus() async {
    try {
      final existingStatus = await databaseService.query('strategy_status');
      if (existingStatus.isEmpty) {
        await databaseService.insert('strategy_status', {'status': 'inactive'});
      }
    } catch (e) {
      print('Error initializing strategy status: $e');
    }
  }

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
    try {
      final statusString = status.toString().split('.').last;
      final existingStatus = await databaseService.query('strategy_status');
      if (existingStatus.isEmpty) {
        await databaseService
            .insert('strategy_status', {'status': statusString});
      } else {
        await databaseService
            .update('strategy_status', {'status': statusString});
      }
    } catch (e) {
      throw Exception('Failed to save strategy status: $e');
    }
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

  Future<void> startDemoStrategy(StrategyParameters parameters) async {
    try {
      print('Starting demo strategy');
      tradingService.setDemoMode(true);
      print('Demo mode set');

      final result = await tradingService.executeStrategy(parameters);
      switch (result) {
        case StrategyExecutionResult.success:
          print('Strategy executed successfully');
          await saveStrategyStatus(StrategyStateStatus.active);
          break;
        case StrategyExecutionResult.tradeNotAllowed:
          print(
              'Strategy execution skipped: Trade not allowed due to risk limits');
          // Potremmo voler gestire questo caso in modo specifico, ad esempio notificando l'utente
          break;
        case StrategyExecutionResult.insufficientTime:
          print(
              'Strategy execution skipped: Insufficient time since last trade');
          // Anche qui, potremmo voler gestire questo caso in modo specifico
          break;
        case StrategyExecutionResult.error:
          throw Exception('Error occurred during strategy execution');
      }
    } catch (e) {
      print('Error in startDemoStrategy: $e');
      throw Exception('Error in strategy execution: $e');
    }
  }

  Future<void> startLiveStrategy(StrategyParameters parameters) async {
    try {
      tradingService.setDemoMode(false);
      await tradingService.executeStrategy(parameters);
      await saveStrategyStatus(StrategyStateStatus.active);
    } catch (e) {
      throw Exception('Failed to start live strategy: $e');
    }
  }

  Future<void> stopStrategy() async {
    try {
      print('Attempting to stop strategy');
      final existingStatus = await databaseService.query('strategy_status');
      if (existingStatus.isEmpty) {
        print('No existing status, inserting new status');
        await databaseService.insert('strategy_status', {'status': 'inactive'});
      } else {
        print('Updating existing status');
        await databaseService.update(
          'strategy_status',
          {'status': 'inactive'},
        );
      }
      print('Strategy stopped successfully');
    } catch (e) {
      print('Error stopping strategy: $e');
      throw Exception('Failed to stop strategy: $e');
    }
  }
}
