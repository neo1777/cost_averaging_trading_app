import 'package:cost_averaging_trading_app/core/models/trade.dart';

abstract class TradingRepository {
  Future<List<CoreTrade>> getTrades();
  Future<void> executeTrade(CoreTrade trade);
}
