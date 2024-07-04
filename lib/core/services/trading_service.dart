import 'package:cost_averaging_trading_app/core/error/error_handler.dart';
import 'package:cost_averaging_trading_app/core/models/strategy_execution_result.dart';
import 'package:cost_averaging_trading_app/core/models/trade.dart';
import 'package:cost_averaging_trading_app/core/services/api_service.dart';
import 'package:cost_averaging_trading_app/core/services/database_service.dart';
import 'package:cost_averaging_trading_app/core/services/risk_management_service.dart';
import 'package:cost_averaging_trading_app/features/strategy/models/strategy_parameters.dart';

class TradingService {
  final ApiService _apiService;
  final DatabaseService _databaseService;
  final RiskManagementService _riskManagementService;
  bool _isDemoMode = false;

  TradingService(
      this._apiService, this._databaseService, this._riskManagementService);

  void setDemoMode(bool isDemoMode) {
    _isDemoMode = isDemoMode;
  }

  Future<void> executeTrade(CoreTrade trade) async {
    try {
      if (_isDemoMode) {
        await _executeDemoTrade(trade);
      } else {
        await _executeLiveTrade(trade);
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError('Failed to execute trade', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _executeDemoTrade(CoreTrade trade) async {
    try {
      double currentPrice = await _apiService.getCurrentPrice(trade.symbol);
      trade = trade.copyWith(price: currentPrice);
      await _databaseService.insert('trades', trade.toJson());
    } catch (e, stackTrace) {
      ErrorHandler.logError('Failed to execute demo trade', e, stackTrace);
      throw Exception('Error in demo trade execution');
    }
  }

  Future<void> _executeLiveTrade(CoreTrade trade) async {
    try {
      await _apiService.createOrder(
        symbol: trade.symbol,
        side: trade.type == CoreTradeType.buy ? 'BUY' : 'SELL',
        type: 'MARKET',
        quantity: trade.amount.toString(),
      );
      await _databaseService.insert('trades', trade.toJson());
    } catch (e, stackTrace) {
      ErrorHandler.logError('Failed to execute live trade', e, stackTrace);
      throw Exception('Error in live trade execution');
    }
  }

Future<StrategyExecutionResult> executeStrategy(StrategyParameters params) async {
  try {
    print('Executing strategy for ${params.symbol}');
    
    final lastPurchaseDate = await _getLastPurchaseDate(params.symbol);
    final now = DateTime.now();
    if (lastPurchaseDate != null &&
        now.difference(lastPurchaseDate).inDays < params.purchaseFrequency) {
      print('Not enough time has passed since last purchase. Skipping execution.');
      return StrategyExecutionResult.insufficientTime;
    }

    print('Fetching current price for ${params.symbol}');
    double currentPrice = await _apiService.getCurrentPrice(params.symbol);
    print('Current price: $currentPrice');

    double amountToBuy = params.investmentAmount / currentPrice;
    amountToBuy = amountToBuy.clamp(0, params.maxInvestmentSize);
    print('Amount to buy: $amountToBuy');

    print('Checking if trade is allowed');
    double currentPortfolioValue = await _getCurrentPortfolioValue();
    bool isTradeAllowed = await _riskManagementService.isCoreTradeAllowed(
      CoreTrade(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        symbol: params.symbol,
        amount: amountToBuy,
        price: currentPrice,
        timestamp: now,
        type: CoreTradeType.buy,
      ),
      currentPortfolioValue,
    );

  if (!isTradeAllowed) {
      print('Trade not allowed: exceeds risk limits');
      return StrategyExecutionResult.tradeNotAllowed;
    }

    print('Creating trade object');
    CoreTrade trade = CoreTrade(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      symbol: params.symbol,
      amount: amountToBuy,
      price: currentPrice,
      timestamp: now,
      type: CoreTradeType.buy,
    );

    print('Executing trade');
    await executeTrade(trade);
    print('Trade executed successfully');

    print('Checking for take profit opportunities');
    await _checkAndExecuteTakeProfit(params);
    print('Strategy execution completed');
   print('Strategy execution completed');
    return StrategyExecutionResult.success;
  } catch (e, stackTrace) {
    ErrorHandler.logError('Failed to execute strategy', e, stackTrace);
    print('Error in strategy execution: $e');
    return StrategyExecutionResult.error;
  }
}
  Future<DateTime?> _getLastPurchaseDate(String symbol) async {
    final lastTrade = await _databaseService.getLastTrade(symbol);
    return lastTrade?.timestamp;
  }

  Future<void> _checkAndExecuteTakeProfit(StrategyParameters params) async {
    List<Map<String, dynamic>> tradeData =
        await _databaseService.query('trades');
    List<CoreTrade> trades =
        tradeData.map((data) => CoreTrade.fromJson(data)).toList();

    if (trades.isEmpty) return;

    double totalAmount = 0;
    double totalValue = 0;
    for (var trade in trades) {
      if (trade.type == CoreTradeType.buy) {
        totalAmount += trade.amount;
        totalValue += trade.amount * trade.price;
      }
    }
    double averagePrice = totalValue / totalAmount;

    double currentPrice = await _getCurrentPrice(params.symbol);

    if (currentPrice >= averagePrice * (1 + params.targetProfitPercentage)) {
      CoreTrade sellTrade = CoreTrade(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        symbol: params.symbol,
        amount: totalAmount,
        price: currentPrice,
        timestamp: DateTime.now(),
        type: CoreTradeType.sell,
      );
      await executeTrade(sellTrade);
    }
  }

  Future<double> _getCurrentPrice(String symbol) async {
    return await _apiService.getCurrentPrice(symbol);
  }

  Future<double> _getCurrentPortfolioValue() async {
    try {
      final accountInfo = await _apiService.getAccountInfo();
      final balances = accountInfo['balances'] as List;
      double totalValue = 0;

      for (var balance in balances) {
        double free = double.parse(balance['free']);
        if (free > 0) {
          if (balance['asset'] != 'USDT') {
            double price =
                await _apiService.getCurrentPrice('${balance['asset']}USDT');
            totalValue += free * price;
          } else {
            totalValue += free;
          }
        }
      }

      return totalValue;
    } catch (e, stackTrace) {
      ErrorHandler.logError(
          'Failed to get current portfolio value', e, stackTrace);
      throw Exception('Error in portfolio value calculation');
    }
  }

  Future<List<CoreTrade>> getTradeHistory(String symbol) async {
    try {
      final orders = await _apiService.getAllOrders(symbol: symbol);
      return orders
          .map<CoreTrade>((order) => CoreTrade(
                id: order['orderId'].toString(),
                symbol: order['symbol'],
                amount: double.parse(order['executedQty']),
                price: double.parse(order['price']),
                timestamp: DateTime.fromMillisecondsSinceEpoch(order['time']),
                type: order['side'] == 'BUY'
                    ? CoreTradeType.buy
                    : CoreTradeType.sell,
              ))
          .toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Failed to get trade history', e, stackTrace);
      // Fallback to local data
      final localData = await _databaseService.query('trades');
      return localData.map((trade) => CoreTrade.fromJson(trade)).toList();
    }
  }

  Future<void> stopStrategy() async {
    try {
      // Logica per fermare la strategia
      // Ad esempio, cancellare tutti gli ordini aperti
      // e aggiornare lo stato della strategia nel database
      await _databaseService.update('strategy_status', {'status': 'inactive'});
    } catch (e) {
      throw Exception('Failed to stop strategy: $e');
    }
  }

  Future<void> cancelOrder(String symbol, String orderId) async {
    try {
      await _apiService.cancelOrder(symbol: symbol, orderId: orderId);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Failed to cancel order', e, stackTrace);
      throw Exception('Error cancelling order');
    }
  }

  Future<List<CoreTrade>> getOpenOrders(String symbol) async {
    try {
      final openOrders = await _apiService.getOpenOrders(symbol: symbol);
      return openOrders
          .map<CoreTrade>((order) => CoreTrade(
                id: order['orderId'].toString(),
                symbol: order['symbol'],
                amount: double.parse(order['origQty']),
                price: double.parse(order['price']),
                timestamp: DateTime.fromMillisecondsSinceEpoch(order['time']),
                type: order['side'] == 'BUY'
                    ? CoreTradeType.buy
                    : CoreTradeType.sell,
              ))
          .toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Failed to get open orders', e, stackTrace);
      throw Exception('Error getting open orders');
    }
  }

  Future<void> updateStrategyParameters(StrategyParameters params) async {
    try {
      await _databaseService.insert('strategy_parameters', params.toJson());
    } catch (e, stackTrace) {
      ErrorHandler.logError(
          'Failed to update strategy parameters', e, stackTrace);
      throw Exception('Error updating strategy parameters');
    }
  }

  Future<StrategyParameters> getStrategyParameters() async {
    try {
      final data = await _databaseService.query('strategy_parameters');
      if (data.isNotEmpty) {
        return StrategyParameters.fromJson(data.first);
      } else {
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
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError('Failed to get strategy parameters', e, stackTrace);
      throw Exception('Error getting strategy parameters');
    }
  }
}
