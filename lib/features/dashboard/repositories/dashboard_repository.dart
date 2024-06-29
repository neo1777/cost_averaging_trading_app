import 'package:cost_averaging_trading_app/core/error/error_handler.dart';
import 'package:cost_averaging_trading_app/core/models/portfolio.dart';
import 'package:cost_averaging_trading_app/core/models/trade.dart';
import 'package:cost_averaging_trading_app/core/services/api_service.dart';
import 'package:cost_averaging_trading_app/core/services/database_service.dart';

class DashboardRepository {
  final ApiService apiService;
  final DatabaseService databaseService;

  DashboardRepository(
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

      final validSymbols = await apiService.getValidTradingSymbols();

      double totalValue = 0;
      for (var entry in assets.entries) {
        if (entry.key != 'USDT') {
          final symbolVariations = [
            '${entry.key}USDT',
            entry.key.endsWith('W')
                ? '${entry.key.substring(0, entry.key.length - 1)}USDT'
                : null,
            'USDT${entry.key}',
          ]
              .whereType<String>()
              .where((symbol) => validSymbols.contains(symbol))
              .toList();

          double? price;
          for (var symbol in symbolVariations) {
            try {
              price = await apiService.getCurrentPrice(symbol);
              break; // Se otteniamo il prezzo con successo, usciamo dal loop
            } catch (e, stackTrace) {
              ErrorHandler.logError(
                  'Error getting price for $symbol', e, stackTrace);
            }
          }

          if (price != null) {
            totalValue += entry.value * price;
          } else {
            ErrorHandler.logError(
                'Unable to get price for asset', null, StackTrace.current);
          }
        } else {
          totalValue += entry.value;
        }
      }

      final portfolio = Portfolio(
        id: accountInfo['accountType'],
        assets: assets,
        totalValue: totalValue,
      );

      // Salva il portfolio nel database locale
      try {
        await databaseService.insert('portfolio', portfolio.toJson());
      } catch (e, stackTrace) {
        ErrorHandler.logError(
            'Error saving portfolio to local database', e, stackTrace);
      }

      return portfolio;
    } catch (e, stackTrace) {
      ErrorHandler.logError('Error fetching portfolio from API', e, stackTrace);
      return _getLocalPortfolio();
    }
  }

  Future<Portfolio> _getLocalPortfolio() async {
    try {
      final localData = await databaseService.query('portfolio');
      if (localData.isNotEmpty) {
        return Portfolio.fromJson(localData.first);
      }
      throw Exception('No local portfolio data available');
    } catch (e, stackTrace) {
      ErrorHandler.logError(
          'Error fetching portfolio from local database', e, stackTrace);
      // Se non c'è nessun dato locale disponibile, ritorna un portfolio vuoto
      return const Portfolio(id: 'local', assets: {}, totalValue: 0);
    }
  }

  Future<List<CoreTrade>> getRecentTrades(
      {required int page, required int perPage}) async {
    try {
      final trades = await apiService.getMyTrades(
          symbol: 'BTCUSDT', limit: perPage, startTime: null);

      final coreTrades = trades
          .map((trade) {
            try {
              return CoreTrade.fromJson(trade);
            } catch (e, stackTrace) {
              ErrorHandler.logError('Error parsing trade', e, stackTrace);
              return null;
            }
          })
          .whereType<CoreTrade>()
          .toList();

      // Salva i trade nel database locale
      for (var trade in coreTrades) {
        try {
          await databaseService.insert('trades', trade.toJson());
        } catch (e, stackTrace) {
          ErrorHandler.logError(
              'Error inserting trade into database', e, stackTrace);
        }
      }

      return coreTrades;
    } catch (e, stackTrace) {
      ErrorHandler.logError('Error fetching trades from API', e, stackTrace);
      return _getLocalTrades(page, perPage);
    }
  }

  Future<List<CoreTrade>> _getLocalTrades(int page, int perPage) async {
    try {
      final localData = await databaseService.query(
        'trades',
        orderBy: 'timestamp DESC',
        limit: perPage,
        offset: (page - 1) * perPage,
      );

      return localData.map((trade) => CoreTrade.fromJson(trade)).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError(
          'Error fetching trades from local database', e, stackTrace);
      return []; // Ritorna una lista vuota se non è possibile recuperare i dati locali
    }
  }

  Future<List<Map<String, dynamic>>> getPerformanceData() async {
    try {
      final klines = await apiService.getKlines(
        symbol: 'BTCUSDT',
        interval: '1d',
        limit: 30,
      );
      return klines
          .map((kline) => {
                'date': DateTime.fromMillisecondsSinceEpoch(kline['0']),
                'value': double.parse(kline['4']), // Closing price
              })
          .toList();
    } catch (e) {
      // Fallback to example data if API call fails
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
  }
}
