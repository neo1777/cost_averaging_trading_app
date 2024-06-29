import 'package:cost_averaging_trading_app/core/models/portfolio.dart';

abstract class PortfolioRepository {
  Future<Portfolio> getPortfolio();
  Future<void> updatePortfolio(Portfolio portfolio);
}
