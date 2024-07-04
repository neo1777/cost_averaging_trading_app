import 'dart:math';
import 'package:cost_averaging_trading_app/core/models/trade.dart';
import 'package:cost_averaging_trading_app/core/services/api_service.dart';
import 'package:cost_averaging_trading_app/core/services/database_service.dart';
import 'package:cost_averaging_trading_app/core/error/error_handler.dart';
import 'package:cost_averaging_trading_app/features/settings/repositories/settings_repository.dart';
import 'package:cost_averaging_trading_app/features/strategy/models/strategy_parameters.dart';

class RiskManagementService {
  final SettingsRepository settingsRepository;
  final ApiService apiService;
  final DatabaseService databaseService;

  RiskManagementService(
      this.settingsRepository, this.apiService, this.databaseService);

  Future<bool> isCoreTradeAllowed(
      CoreTrade proposedCoreTrade, double currentPortfolioValue) async {
    //final settings = await settingsRepository.getSettings();
    try {
      if (!await _isWithinVolatilityLimits(proposedCoreTrade)) {
        return false;
      }

      if (!await _isWithinMaxRebuyLimit(proposedCoreTrade)) {
        return false;
      }

      if (!await _isAboveStopLoss(proposedCoreTrade, currentPortfolioValue)) {
        return false;
      }

      if (!await _isWithinMaxPositionSize(
          proposedCoreTrade, currentPortfolioValue)) {
        return false;
      }

      if (!await _isWithinDailyExposureLimit(proposedCoreTrade)) {
        return false;
      }

      return true;
    } catch (e, stackTrace) {
      ErrorHandler.logError('Error in isCoreTradeAllowed', e, stackTrace);
      return false;
    }
  }

  Future<bool> isStrategySafe(StrategyParameters parameters) async {
    try {
      final settings = await settingsRepository.getSettings();

      // Check if the investment amount is within limits
      if (parameters.investmentAmount >
          settings.maxPositionSizePercentage *
              await _getCurrentPortfolioValue()) {
        return false;
      }

      // Check if the symbol's volatility is within acceptable limits
      double volatility = await _calculateVolatility(parameters.symbol);
      if (volatility > settings.maxAllowedVolatility) {
        return false;
      }

      // Add more checks as needed

      return true;
    } catch (e, stackTrace) {
      ErrorHandler.logError('Error in isStrategySafe', e, stackTrace);
      return false;
    }
  }

  Future<bool> _isWithinVolatilityLimits(CoreTrade trade) async {
    try {
      double volatility = await _calculateVolatility(trade.symbol);
      final settings = await settingsRepository.getSettings();

      return volatility <= settings.maxAllowedVolatility;
    } catch (e, stackTrace) {
      ErrorHandler.logError(
          'Error in _isWithinVolatilityLimits', e, stackTrace);
      return false;
    }
  }

  Future<bool> _isWithinMaxRebuyLimit(CoreTrade trade) async {
    try {
      int rebuyCount = await _getRebuyCount(trade.symbol);
      final settings = await settingsRepository.getSettings();

      return rebuyCount < settings.maxRebuyCount;
    } catch (e, stackTrace) {
      ErrorHandler.logError('Error in _isWithinMaxRebuyLimit', e, stackTrace);
      return false;
    }
  }

  Future<bool> _isAboveStopLoss(
      CoreTrade trade, double currentPortfolioValue) async {
    double potentialLoss =
        (currentPortfolioValue - (trade.amount * trade.price)) /
            currentPortfolioValue;
    final settings = await settingsRepository.getSettings();

    return potentialLoss <= settings.maxLossPercentage;
  }

  Future<bool> _isWithinMaxPositionSize(
      CoreTrade trade, double currentPortfolioValue) async {
    double tradeValue = trade.amount * trade.price;
    final settings = await settingsRepository.getSettings();

    double maxPositionSize =
        currentPortfolioValue * settings.maxPositionSizePercentage;
    return tradeValue <= maxPositionSize;
  }

  Future<bool> _isWithinDailyExposureLimit(CoreTrade trade) async {
    try {
      double dailyExposure = await _calculateDailyExposure(trade.symbol);
      final settings = await settingsRepository.getSettings();

      return dailyExposure + (trade.amount * trade.price) <=
          settings.dailyExposureLimit;
    } catch (e, stackTrace) {
      ErrorHandler.logError(
          'Error in _isWithinDailyExposureLimit', e, stackTrace);
      return false;
    }
  }

  Future<double> _calculateVolatility(String symbol) async {
    try {
      var klineData = await apiService.getKlines(
        symbol: symbol,
        interval: '1d',
        limit: 30,
      );

      List<double> closePrices =
          klineData.map<double>((k) => double.parse(k['4'])).toList();

      List<double> logReturns = [];
      for (int i = 1; i < closePrices.length; i++) {
        logReturns.add(log(closePrices[i] / closePrices[i - 1]));
      }

      double mean = logReturns.reduce((a, b) => a + b) / logReturns.length;
      double variance =
          logReturns.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) /
              logReturns.length;
      double stdDev = sqrt(variance);

      return stdDev * sqrt(365);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Error in _calculateVolatility', e, stackTrace);
      return double.infinity;
    }
  }

  Future<int> _getRebuyCount(String symbol) async {
    try {
      var sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      var recentTrades =
          await databaseService.getRecentTrades(symbol, sevenDaysAgo);
      return recentTrades.where((trade) => trade['type'] == 'buy').length;
    } catch (e, stackTrace) {
      final settings = await settingsRepository.getSettings();

      ErrorHandler.logError('Error in _getRebuyCount', e, stackTrace);
      return settings.maxRebuyCount;
    }
  }

  Future<double> _calculateDailyExposure(String symbol) async {
    try {
      var todayTrades = await databaseService.getTodayTrades(symbol);
      double totalExposure = 0.0;
      for (var trade in todayTrades) {
        totalExposure += trade['amount'] * trade['price'];
      }
      return totalExposure;
    } catch (e, stackTrace) {
      final settings = await settingsRepository.getSettings();

      ErrorHandler.logError('Error in _calculateDailyExposure', e, stackTrace);
      return settings.dailyExposureLimit;
    }
  }

  Future<double> _getCurrentPortfolioValue() async {
    try {
      // Prova prima a ottenere il valore del portfolio dall'API
      final accountInfo = await apiService.getAccountInfo();
      double totalValue = 0.0;

      for (var balance in accountInfo['balances']) {
        String asset = balance['asset'];
        double free = double.parse(balance['free']);
        double locked = double.parse(balance['locked']);
        double totalAssetAmount = free + locked;

        if (totalAssetAmount > 0) {
          if (asset != 'USDT') {
            // Se l'asset non è USDT, ottieni il prezzo corrente e calcola il valore
            String symbol = '${asset}USDT';
            double price = await apiService.getCurrentPrice(symbol);
            totalValue += totalAssetAmount * price;
          } else {
            // Se l'asset è USDT, aggiungi direttamente il valore
            totalValue += totalAssetAmount;
          }
        }
      }

      // Salva il valore del portfolio nel database locale per uso futuro
      await databaseService.insert('portfolio_value', {
        'value': totalValue,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      return totalValue;
    } catch (e) {
      // Se c'è un errore nell'ottenere i dati dall'API, prova a recuperare l'ultimo valore salvato dal database
      try {
        final lastValue = await databaseService.query(
          'portfolio_value',
          orderBy: 'timestamp DESC',
          limit: 1,
        );

        if (lastValue.isNotEmpty) {
          return lastValue.first['value'];
        }
      } catch (dbError,stacktrace) {
        ErrorHandler.logError('Error retrieving portfolio value from database: ', dbError,stacktrace);
      }

      // Se non è possibile recuperare il valore né dall'API né dal database, lancia un'eccezione
      throw Exception('Unable to get current portfolio value');
    }
  }
}
