// lib/core/models/portfolio.dart

import 'package:equatable/equatable.dart';

class Portfolio extends Equatable {
  final String id;
  final Map<String, double> assets;
  final double totalValue;

  const Portfolio({
    required this.id,
    required this.assets,
    required this.totalValue,
  });

  @override
  List<Object?> get props => [id, assets, totalValue];

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['id'],
      assets: Map<String, double>.from(json['assets']),
      totalValue: json['totalValue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assets': assets,
      'totalValue': totalValue,
    };
  }
}
