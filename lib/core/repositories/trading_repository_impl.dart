import 'package:cost_averaging_trading_app/core/models/trade.dart';
import 'package:cost_averaging_trading_app/core/repositories/trading_repository.dart';
import 'package:cost_averaging_trading_app/core/services/api_service.dart';
import 'package:cost_averaging_trading_app/core/services/database_service.dart';
import 'package:cost_averaging_trading_app/features/settings/models/settings_model.dart';

class TradingRepositoryImpl implements TradingRepository {
  final ApiService _apiService;
  final DatabaseService _databaseService;
  final SettingsModel _settings;

  TradingRepositoryImpl(
      this._apiService, this._databaseService, this._settings);

  @override
  Future<List<CoreTrade>> getTrades() async {
    if (_settings.isDemoMode) {
      return _getDemoTrades();
    } else {
      try {
        final json = await _apiService.get('trades');
        final trades = (json['trades'] as List)
            .map((e) => CoreTrade(
                  id: e['id'],
                  symbol: e['symbol'],
                  amount: e['amount'],
                  price: e['price'],
                  timestamp:
                      DateTime.fromMillisecondsSinceEpoch(e['timestamp']),
                  type: e['type'],
                ))
            .toList();
        return trades;
      } catch (e) {
        // If API call fails, try to get data from local database
        final data = await _databaseService.query('trades');
        return data
            .map((e) => CoreTrade(
                  id: e['id'],
                  symbol: e['symbol'],
                  amount: e['amount'],
                  price: e['price'],
                  timestamp: DateTime.fromMillisecondsSinceEpoch(
                    e['timestamp'],
                  ),
                  type: e['type'],
                ))
            .toList();
      }
    }
  }

  @override
  Future<void> executeTrade(CoreTrade trade) async {
    if (_settings.isDemoMode) {
      await _executeDemoTrade(trade);
    } else {
      try {
        await _apiService.post('trades', {
          'symbol': trade.symbol,
          'amount': trade.amount,
          'price': trade.price,
        });
      } catch (e) {
        // If API call fails, save to local database
        await _databaseService.insert('trades', {
          'id': trade.id,
          'symbol': trade.symbol,
          'amount': trade.amount,
          'price': trade.price,
          'timestamp': trade.timestamp.millisecondsSinceEpoch,
        });
      }
    }
  }

  Future<List<CoreTrade>> _getDemoTrades() async {
    // Recupera le operazioni demo dal database locale
    final data = await _databaseService.query('demo_trades');
    return data
        .map(
          (e) => CoreTrade(
            id: e['id'],
            symbol: e['symbol'],
            amount: e['amount'],
            price: e['price'],
            timestamp: DateTime.fromMillisecondsSinceEpoch(e['timestamp']),
            type: e['type'],
          ),
        )
        .toList();
  }

  Future<void> _executeDemoTrade(CoreTrade trade) async {
    // Salva l'operazione demo nel database locale
    await _databaseService.insert('demo_trades', {
      'id': trade.id,
      'symbol': trade.symbol,
      'amount': trade.amount,
      'price': trade.price,
      'timestamp': trade.timestamp.millisecondsSinceEpoch,
    });
  }
}
