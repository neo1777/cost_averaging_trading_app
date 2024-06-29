class TradeHistoryTrade {
  final String id;
  final String assetPair;
  final double amount;
  final double price;
  final DateTime timestamp;
  final String type; // 'buy' o 'sell'

  TradeHistoryTrade({
    required this.id,
    required this.assetPair,
    required this.amount,
    required this.price,
    required this.timestamp,
    required this.type,
  });

  factory TradeHistoryTrade.fromJson(Map<String, dynamic> json) {
    return TradeHistoryTrade(
      id: json['id'],
      assetPair: json['assetPair'],
      amount: json['amount'].toDouble(),
      price: json['price'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetPair': assetPair,
      'amount': amount,
      'price': price,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }
}

class TradeHistoryModel {
  final List<TradeHistoryTrade> trades;

  TradeHistoryModel({required this.trades});

  factory TradeHistoryModel.fromJson(Map<String, dynamic> json) {
    var tradeList = json['trades'] as List;
    List<TradeHistoryTrade> trades =
        tradeList.map((i) => TradeHistoryTrade.fromJson(i)).toList();
    return TradeHistoryModel(trades: trades);
  }

  Map<String, dynamic> toJson() {
    return {
      'trades': trades.map((trade) => trade.toJson()).toList(),
    };
  }
}
