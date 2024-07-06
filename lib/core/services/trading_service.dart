import 'dart:math';
import 'package:cost_averaging_trading_app/core/models/trade.dart';
import 'package:cost_averaging_trading_app/core/services/api_service.dart';
import 'package:cost_averaging_trading_app/core/services/database_service.dart';
import 'package:cost_averaging_trading_app/features/strategy/models/strategy_parameters.dart';
import 'package:cost_averaging_trading_app/features/strategy/repositories/strategy_repository.dart';

class TradingService {
  final ApiService _apiService;
  final DatabaseService _databaseService;
  final StrategyRepository _strategyRepository;

  TradingService(
    this._apiService,
    this._databaseService,
    this._strategyRepository,
  );

  Future<double> getCurrentPrice(String symbol) async {
    try {
      // Tenta di ottenere il prezzo corrente dall'API
      final price = await _apiService.getCurrentPrice(symbol);

      // Salva il prezzo nel database locale per uso futuro
      await _databaseService.insert('price_history', {
        'symbol': symbol,
        'price': price,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      return price;
    } catch (e) {

      // Se fallisce l'API, prova a ottenere l'ultimo prezzo salvato dal database
      try {
        final latestPrice = await _databaseService.query(
          'price_history',
          where: 'symbol = ?',
          whereArgs: [symbol],
          orderBy: 'timestamp DESC',
          limit: 1,
        );

        if (latestPrice.isNotEmpty) {
          return latestPrice.first['price'];
        }
      } catch (dbError) {
              throw Exception('dbError: $dbError');

      }

      // Se non riesce a ottenere il prezzo né dall'API né dal database, lancia un'eccezione
      throw Exception('Unable to get current price for $symbol');
    }
  }

  Future<void> sellEntirePortfolio(String symbol, double targetProfit) async {
    try {
      // Ottieni il saldo attuale per il simbolo specificato
      final balance = await _apiService.getAccountBalance(symbol);

      if (balance > 0) {
        // Crea un ordine di vendita al mercato per l'intero saldo
        final order = await _apiService.createMarketSellOrder(symbol, balance);

        // Assumiamo che l'API restituisca il prezzo medio di esecuzione
        final executionPrice = double.parse(order['avgPrice'] ?? '0');

        // Registra la transazione nel database
        await _databaseService.insert('trades', {
          'symbol': symbol,
          'amount': balance,
          'price': executionPrice,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'type': 'sell',
        });

        // Aggiorna le statistiche
        final currentStats = await _strategyRepository.getStrategyStatistics();
        final updatedStats = {
          ...currentStats,
          'totalInvested': 0.0,
          'totalProfit': currentStats['totalProfit'] + targetProfit,
          'totalTrades': currentStats['totalTrades'] + 1,
        };
        await _databaseService.insert('strategy_statistics', updatedStats);
      }
    } catch (e) {
      // Gestisci eventuali errori
      throw Exception('Failed to sell entire portfolio: $e');
    }
  }

  Future<void> executeStrategy(StrategyParameters params) async {
    try {
      double currentPrice = await _apiService.getCurrentPrice(params.symbol);
      double minimumTradableAmount = params.useAutoMinTradeAmount
          ? await _apiService.getMinimumTradeAmount(params.symbol)
          : params.manualMinTradeAmount;

      double amountToBuy =
          _calculateBuyAmount(params, minimumTradableAmount, currentPrice);

      if (await _shouldBuy(params, currentPrice)) {
        await _executeBuy(params.symbol, amountToBuy, currentPrice,
            params.isVariableInvestmentAmount);
      } else if (await _shouldSell(params, currentPrice)) {
        await _executeSell(params, currentPrice);
      }

      await _checkAndExecuteTakeProfit(params);
    } catch (e) {
      throw Exception('Failed to execute strategy: $e');
    }
  }

  double _calculateBuyAmount(StrategyParameters params,
      double minimumTradableAmount, double currentPrice) {
    double baseAmount = params.investmentAmount;
    if (params.isVariableInvestmentAmount) {
      double variationPercentage = (params.variableInvestmentPercentage / 100);
      double randomFactor =
          1 + (Random().nextDouble() * 2 - 1) * variationPercentage;
      baseAmount *= randomFactor;
    }
    return (baseAmount / currentPrice)
        .clamp(minimumTradableAmount, params.maxInvestmentSize);
  }

  Future<bool> _shouldBuy(
      StrategyParameters params, double currentPrice) async {
    Portfolio portfolio = await _getPortfolio(params.symbol);
    return currentPrice <=
        portfolio.averagePrice * (1 - params.stopLossPercentage / 100);
  }

  Future<bool> _shouldSell(
      StrategyParameters params, double currentPrice) async {
    Portfolio portfolio = await _getPortfolio(params.symbol);
    return currentPrice >=
        portfolio.averagePrice * (1 + params.targetProfitPercentage / 100);
  }

  Future<void> _executeBuy(String symbol, double amount, double price,
      bool isVariableInvestment) async {
    CoreTrade trade = CoreTrade(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      symbol: symbol,
      amount: amount,
      price: price,
      timestamp: DateTime.now(),
      type: CoreTradeType.buy,
    );

    await _strategyRepository.saveTradeWithNewFields(
        trade, isVariableInvestment, null);
  }

  Future<void> _executeSell(
      StrategyParameters params, double currentPrice) async {
    Portfolio portfolio = await _getPortfolio(params.symbol);
    CoreTrade trade = CoreTrade(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      symbol: params.symbol,
      amount: portfolio.totalAmount,
      price: currentPrice,
      timestamp: DateTime.now(),
      type: CoreTradeType.sell,
    );

    double profit =
        (currentPrice - portfolio.averagePrice) * portfolio.totalAmount;
    await _strategyRepository.saveTradeWithNewFields(trade, false, null);

    if (params.reinvestProfits) {
      await _reinvestProfit(params.symbol, profit, currentPrice);
    }
  }

  Future<void> _reinvestProfit(
      String symbol, double profit, double currentPrice) async {
    double amountToBuy = profit / currentPrice;
    CoreTrade reinvestmentTrade = CoreTrade(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      symbol: symbol,
      amount: amountToBuy,
      price: currentPrice,
      timestamp: DateTime.now(),
      type: CoreTradeType.buy,
    );

    await _strategyRepository.saveTradeWithNewFields(
        reinvestmentTrade, false, profit);
  }

  Future<void> _checkAndExecuteTakeProfit(StrategyParameters params) async {
    double currentPrice = await _apiService.getCurrentPrice(params.symbol);
    Portfolio portfolio = await _getPortfolio(params.symbol);

    if (currentPrice >=
        portfolio.averagePrice * (1 + params.targetProfitPercentage / 100)) {
      await _executeSell(params, currentPrice);
    }
  }

  Future<Portfolio> _getPortfolio(String symbol) async {
    List<CoreTrade> trades = await _strategyRepository.getRecentTrades(1000);
    trades = trades.where((trade) => trade.symbol == symbol).toList();

    double totalAmount = 0;
    double totalValue = 0;

    for (var trade in trades) {
      if (trade.type == CoreTradeType.buy) {
        totalAmount += trade.amount;
        totalValue += trade.amount * trade.price;
      } else {
        totalAmount -= trade.amount;
        totalValue -= trade.amount * trade.price;
      }
    }

    double averagePrice = totalAmount > 0 ? totalValue / totalAmount : 0;

    return Portfolio(
      symbol: symbol,
      totalAmount: totalAmount,
      averagePrice: averagePrice,
    );
  }
}

class Portfolio {
  final String symbol;
  final double totalAmount;
  final double averagePrice;

  Portfolio({
    required this.symbol,
    required this.totalAmount,
    required this.averagePrice,
  });
}
