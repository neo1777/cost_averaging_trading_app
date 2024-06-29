import 'package:equatable/equatable.dart';

class PortfolioEntity extends Equatable {
  final String id;
  final Map<String, double> assets;
  final double totalValue;

  const PortfolioEntity({
    required this.id,
    required this.assets,
    required this.totalValue,
  });

  @override
  List<Object?> get props => [id, assets, totalValue];
}