import 'package:equatable/equatable.dart';
import 'package:cost_averaging_trading_app/core/models/portfolio.dart';
import 'package:cost_averaging_trading_app/core/models/trade.dart';
import 'package:cost_averaging_trading_app/features/strategy/models/strategy_parameters.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final Portfolio portfolio;
  final List<CoreTrade> recentTrades;
  final List<Map<String, dynamic>> performanceData;
  final int currentPage;
  final int tradesPerPage;
  final StrategyParameters? activeStrategy; // Aggiunto questo campo

  const DashboardLoaded({
    required this.portfolio,
    required this.recentTrades,
    required this.performanceData,
    required this.currentPage,
    required this.tradesPerPage,
    this.activeStrategy, // Aggiunto questo parametro
  });

  DashboardLoaded copyWith({
    Portfolio? portfolio,
    List<CoreTrade>? recentTrades,
    List<Map<String, dynamic>>? performanceData,
    int? currentPage,
    int? tradesPerPage,
    StrategyParameters? activeStrategy, // Aggiunto questo parametro
  }) {
    return DashboardLoaded(
      portfolio: portfolio ?? this.portfolio,
      recentTrades: recentTrades ?? this.recentTrades,
      performanceData: performanceData ?? this.performanceData,
      currentPage: currentPage ?? this.currentPage,
      tradesPerPage: tradesPerPage ?? this.tradesPerPage,
      activeStrategy:
          activeStrategy ?? this.activeStrategy, // Aggiunto questo campo
    );
  }

  @override
  List<Object?> get props => [
        portfolio,
        recentTrades,
        performanceData,
        currentPage,
        tradesPerPage,
        activeStrategy
      ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}
