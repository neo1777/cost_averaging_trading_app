class PortfolioModel {
  final Map<String, double> assets;
  final List<Transaction> transactions;

  PortfolioModel({
    required this.assets,
    required this.transactions,
  });
}

class Transaction {
  final String id;
  final String assetSymbol;
  final double amount;
  final double price;
  final DateTime timestamp;

  Transaction({
    required this.id,
    required this.assetSymbol,
    required this.amount,
    required this.price,
    required this.timestamp,
  });
}