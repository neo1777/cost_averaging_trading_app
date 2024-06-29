import 'dart:convert';

class PortfolioDTO {
  final String id;
  final Map<String, double> assets;
  final double totalValue;

  PortfolioDTO({
    required this.id,
    required this.assets,
    required this.totalValue,
  });

  factory PortfolioDTO.fromJson(Map<String, dynamic> json) {
    return PortfolioDTO(
      id: json['id'],
      assets: Map<String, double>.from(json['assets']),
      totalValue: json['totalValue'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assets': assets,
      'totalValue': totalValue,
    };
  }

  factory PortfolioDTO.fromDatabase(Map<String, dynamic> data) {
    return PortfolioDTO(
      id: data['id'],
      assets: Map<String, double>.from(json.decode(data['assets'])),
      totalValue: data['totalValue'],
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'assets': json.encode(assets),
      'totalValue': totalValue,
    };
  }
}
