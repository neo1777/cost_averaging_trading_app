import 'package:cost_averaging_trading_app/core/dtos/trade_dto.dart';
import 'package:cost_averaging_trading_app/core/domain/entities/trade_entity.dart';

class TradeMapper {
  static TradeEntity fromDTO(TradeDTO dto) {
    return TradeEntity(
      id: dto.id,
      symbol: dto.symbol,
      amount: dto.amount,
      price: dto.price,
      timestamp: dto.timestamp,
      type: TradeType.values
          .firstWhere((e) => e.toString().split('.').last == dto.type),
    );
  }

  static TradeDTO toDTO(TradeEntity entity) {
    return TradeDTO(
      id: entity.id,
      symbol: entity.symbol,
      amount: entity.amount,
      price: entity.price,
      timestamp: entity.timestamp,
      type: entity.type.toString().split('.').last,
    );
  }
}
