import 'package:cost_averaging_trading_app/core/dtos/portfolio_dto.dart';
import 'package:cost_averaging_trading_app/core/domain/entities/portfolio_entity.dart';

class PortfolioMapper {
  static PortfolioEntity fromDTO(PortfolioDTO dto) {
    return PortfolioEntity(
      id: dto.id,
      assets: dto.assets,
      totalValue: dto.totalValue,
    );
  }

  static PortfolioDTO toDTO(PortfolioEntity entity) {
    return PortfolioDTO(
      id: entity.id,
      assets: entity.assets,
      totalValue: entity.totalValue,
    );
  }
}
