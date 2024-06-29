import 'package:cost_averaging_trading_app/core/models/trade.dart';

class DashboardModel {
  final String portfolioValue;
  final String activeTrades;
  final String totalProfit;
  final String totalLoss;
  final List<CoreTrade> recentTrades;
  final List<PortfolioItem> portfolioItems;
  final List<Notification> notifications;

  DashboardModel({
    required this.portfolioValue,
    required this.activeTrades,
    required this.totalProfit,
    required this.totalLoss,
    required this.recentTrades,
    required this.portfolioItems,
    required this.notifications,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      portfolioValue: json['portfolioValue'],
      activeTrades: json['activeTrades'],
      totalProfit: json['totalProfit'],
      totalLoss: json['totalLoss'],
      recentTrades: (json['recentTrades'] as List)
          .map((i) => CoreTrade.fromJson(i))
          .toList(),
      portfolioItems: (json['portfolioItems'] as List)
          .map((i) => PortfolioItem.fromJson(i))
          .toList(),
      notifications: (json['notifications'] as List)
          .map((i) => Notification.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'portfolioValue': portfolioValue,
      'activeTrades': activeTrades,
      'totalProfit': totalProfit,
      'totalLoss': totalLoss,
      'recentTrades': recentTrades.map((e) => e.toJson()).toList(),
      'portfolioItems': portfolioItems.map((e) => e.toJson()).toList(),
      'notifications': notifications.map((e) => e.toJson()).toList(),
    };
  }
}

class PortfolioItem {
  final String asset;
  final double amount;
  final double value;

  PortfolioItem({
    required this.asset,
    required this.amount,
    required this.value,
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      asset: json['asset'],
      amount: json['amount'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset': asset,
      'amount': amount,
      'value': value,
    };
  }
}

class Notification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}