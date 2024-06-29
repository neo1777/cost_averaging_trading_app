// lib/routes.dart
import 'package:flutter/material.dart';

import 'package:cost_averaging_trading_app/features/dashboard/ui/pages/dashboard_page.dart';
import 'package:cost_averaging_trading_app/features/portfolio/ui/pages/portfolio_page.dart';
import 'package:cost_averaging_trading_app/features/settings/ui/pages/settings_page.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/pages/strategy_page.dart';
import 'package:cost_averaging_trading_app/features/trade_history/ui/pages/trade_history_page.dart';
import 'package:cost_averaging_trading_app/ui/layouts/main_layout.dart'; // Aggiungi questa importazione

class Routes {
  static const String dashboard = '/';
  static const String portfolio = '/portfolio';
  static const String strategy = '/strategy';
  static const String tradeHistory = '/trade-history';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings setting) {
    switch (setting.name) {
      case dashboard:
        return MaterialPageRoute(
            builder: (_) => const MainLayout(child: DashboardPage()));
      case portfolio:
        return MaterialPageRoute(
            builder: (_) => const MainLayout(child: PortfolioPage()));
      case strategy:
        return MaterialPageRoute(
            builder: (_) => const MainLayout(child: StrategyPage()));
      case tradeHistory:
        return MaterialPageRoute(
            builder: (_) => const MainLayout(child: TradeHistoryPage()));
      case settings:
        return MaterialPageRoute(
            builder: (_) => const MainLayout(child: SettingsPage()));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${setting.name}'),
            ),
          ),
        );
    }
  }
}
