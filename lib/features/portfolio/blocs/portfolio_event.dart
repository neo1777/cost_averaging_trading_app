// lib/features/portfolio/blocs/portfolio_event.dart

import 'package:equatable/equatable.dart';

abstract class PortfolioEvent extends Equatable {
  const PortfolioEvent();

  @override
  List<Object> get props => [];
}

class LoadPortfolio extends PortfolioEvent {}
