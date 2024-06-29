import 'dart:math';
import 'package:cost_averaging_trading_app/core/models/trade.dart';
import 'package:cost_averaging_trading_app/features/settings/models/settings_model.dart';
import 'package:cost_averaging_trading_app/core/services/api_service.dart';
import 'package:cost_averaging_trading_app/core/services/database_service.dart';
import 'package:cost_averaging_trading_app/core/error/error_handler.dart';
import 'package:flutter/foundation.dart';

class RiskManagementService {
  final SettingsModel settings;
  final ApiService apiService;
  final DatabaseService databaseService;

  RiskManagementService(this.settings, this.apiService, this.databaseService);

  Future<bool> isCoreTradeAllowed(
      CoreTrade proposedCoreTrade, double currentPortfolioValue) async {
    try {
      if (!await _isWithinVolatilityLimits(proposedCoreTrade)) {
        return false;
      }

      if (!await _isWithinMaxRebuyLimit(proposedCoreTrade)) {
        return false;
      }

      if (!_isAboveStopLoss(proposedCoreTrade, currentPortfolioValue)) {
        return false;
      }

      if (!_isWithinMaxPositionSize(proposedCoreTrade, currentPortfolioValue)) {
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

  Future<bool> _isWithinVolatilityLimits(CoreTrade trade) async {
    try {
      double volatility = await _calculateVolatility(trade.symbol);
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
      return rebuyCount < settings.maxRebuyCount;
    } catch (e, stackTrace) {
      ErrorHandler.logError('Error in _isWithinMaxRebuyLimit', e, stackTrace);
      return false;
    }
  }

  bool _isAboveStopLoss(CoreTrade trade, double currentPortfolioValue) {
    double potentialLoss =
        (currentPortfolioValue - (trade.amount * trade.price)) /
            currentPortfolioValue;
    return potentialLoss <= settings.maxLossPercentage;
  }

  bool _isWithinMaxPositionSize(CoreTrade trade, double currentPortfolioValue) {
    double tradeValue = trade.amount * trade.price;
    double maxPositionSize =
        currentPortfolioValue * settings.maxPositionSizePercentage;
    return tradeValue <= maxPositionSize;
  }

  Future<bool> _isWithinDailyExposureLimit(CoreTrade trade) async {
    try {
      double dailyExposure = await _calculateDailyExposure(trade.symbol);
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
      ErrorHandler.logError('Error in _calculateDailyExposure', e, stackTrace);
      return settings.dailyExposureLimit;
    }
  }
}
