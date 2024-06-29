import 'package:cost_averaging_trading_app/core/dtos/portfolio_dto.dart';
import 'package:cost_averaging_trading_app/core/models/portfolio.dart';
import 'package:cost_averaging_trading_app/core/repositories/portfolio_repository.dart';
import 'package:cost_averaging_trading_app/core/services/api_service.dart';
import 'package:cost_averaging_trading_app/core/services/database_service.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  final ApiService _apiService;
  final DatabaseService _databaseService;

  PortfolioRepositoryImpl(this._apiService, this._databaseService);

  @override
  Future<Portfolio> getPortfolio() async {
    try {
      final json = await _apiService.get('portfolio');
      final dto = PortfolioDTO.fromJson(json);
      return Portfolio(
        id: dto.id,
        assets: dto.assets,
        totalValue: dto.totalValue,
      );
    } catch (e) {
      // If API call fails, try to get data from local database
      final data = await _databaseService.query('portfolio');
      if (data.isNotEmpty) {
        final dto = PortfolioDTO.fromDatabase(data.first);
        return Portfolio(
          id: dto.id,
          assets: dto.assets,
          totalValue: dto.totalValue,
        );
      }
      throw Exception('Failed to get portfolio data');
    }
  }

  @override
  Future<void> updatePortfolio(Portfolio portfolio) async {
    final dto = PortfolioDTO(
      id: portfolio.id,
      assets: portfolio.assets,
      totalValue: portfolio.totalValue,
    );
    try {
      await _apiService.post('portfolio', dto.toJson());
    } catch (e) {
      // If API call fails, update local database
      await _databaseService.insert('portfolio', dto.toDatabase());
    }
  }
}
