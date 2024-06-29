import 'package:cost_averaging_trading_app/core/models/trade.dart';

class TradeHistoryRepository {
  Future<List<CoreTrade>> getTradeHistory() async {
    // Simulazione di una chiamata API
    await Future.delayed(const Duration(seconds: 1));
    
    // Dati di esempio
    return [
      CoreTrade(
        id: '1',
        symbol: 'BTC/USDT',
        amount: 0.1,
        price: 50000,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: CoreTradeType.sell,
      ),
      CoreTrade(
        id: '2',
        symbol: 'ETH/USDT',
        amount: 1.5,
        price: 3000,
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        type: CoreTradeType.sell,
      ),
      // Aggiungi altri trade di esempio qui
    ];
  }

  Future<List<CoreTrade>> getFilteredTradeHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? assetPair,
  }) async {
    // Simulazione di una chiamata API con filtri
    await Future.delayed(const Duration(seconds: 1));
    
    List<CoreTrade> allTrades = await getTradeHistory();
    
    return allTrades.where((trade) {
      bool dateCondition = true;
      if (startDate != null) {
        dateCondition = dateCondition && trade.timestamp.isAfter(startDate);
      }
      if (endDate != null) {
        dateCondition = dateCondition && trade.timestamp.isBefore(endDate);
      }
      bool assetCondition = assetPair == null || trade.symbol == assetPair;
      
      return dateCondition && assetCondition;
    }).toList();
  }
}