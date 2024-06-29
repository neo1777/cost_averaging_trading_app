class TradeDTO {
  final String id;
  final String symbol;
  final double amount;
  final double price;
  final DateTime timestamp;
  final String type;

  TradeDTO({
    required this.id,
    required this.symbol,
    required this.amount,
    required this.price,
    required this.timestamp,
    required this.type,
  });

  factory TradeDTO.fromJson(Map<String, dynamic> json) {
    return TradeDTO(
      id: json['id'],
      symbol: json['symbol'],
      amount: json['amount'],
      price: json['price'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'amount': amount,
      'price': price,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }
}
