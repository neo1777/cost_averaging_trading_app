import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:cost_averaging_trading_app/core/services/api_service.dart';
import 'package:cost_averaging_trading_app/core/services/backtesting_service.dart';
import 'package:cost_averaging_trading_app/core/services/database_service.dart';
import 'package:cost_averaging_trading_app/core/services/risk_management_service.dart';
import 'package:cost_averaging_trading_app/core/services/secure_storage_service.dart';
import 'package:cost_averaging_trading_app/core/services/trading_service.dart';
import 'package:cost_averaging_trading_app/features/dashboard/blocs/dashboard_bloc.dart';
import 'package:cost_averaging_trading_app/features/dashboard/repositories/dashboard_repository.dart';
import 'package:cost_averaging_trading_app/features/portfolio/blocs/portfolio_bloc.dart';
import 'package:cost_averaging_trading_app/features/portfolio/repositories/portfolio_repository.dart';
import 'package:cost_averaging_trading_app/features/settings/blocs/settings_bloc.dart';
import 'package:cost_averaging_trading_app/features/settings/repositories/settings_repository.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_bloc.dart';
import 'package:cost_averaging_trading_app/features/strategy/repositories/strategy_repository.dart';
import 'package:cost_averaging_trading_app/features/trade_history/blocs/trade_history_bloc.dart';
import 'package:cost_averaging_trading_app/features/trade_history/repositories/trade_history_repository.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiService>(
          create: (context) => ApiService(
            apiKey: dotenv.env['API_KEY'] ?? '',
            secretKey: dotenv.env['SECRET_KEY'] ?? '',
          ),
        ),
        RepositoryProvider<DatabaseService>(
          create: (context) {
            final databaseService = DatabaseService();
            _initializeDatabase(databaseService);
            return databaseService;
          },
        ),
        RepositoryProvider<SecureStorageService>(
          create: (context) => SecureStorageService(),
        ),
        RepositoryProvider<SettingsRepository>(
          create: (context) =>
              SettingsRepository(context.read<SecureStorageService>()),
        ),
        RepositoryProvider<RiskManagementService>(
          create: (context) => RiskManagementService(
            context.read<SettingsRepository>(),
            context.read<ApiService>(),
            context.read<DatabaseService>(),
          ),
        ),
        RepositoryProvider<StrategyRepository>(
          create: (context) => StrategyRepository(
            databaseService: context.read<DatabaseService>(),
          ),
        ),
        RepositoryProvider<TradingService>(
          create: (context) => TradingService(
            context.read<ApiService>(),
            context.read<DatabaseService>(),
            context.read<StrategyRepository>(),
          ),
        ),
        RepositoryProvider<DashboardRepository>(
          create: (context) => DashboardRepository(
            apiService: context.read<ApiService>(),
            databaseService: context.read<DatabaseService>(),
          ),
        ),
        RepositoryProvider<PortfolioRepository>(
          create: (context) => PortfolioRepository(
            apiService: context.read<ApiService>(),
            databaseService: context.read<DatabaseService>(),
          ),
        ),
        RepositoryProvider<TradeHistoryRepository>(
          create: (context) => TradeHistoryRepository(),
        ),
        RepositoryProvider<BacktestingService>(
          create: (context) => BacktestingService(context.read<ApiService>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<DashboardBloc>(
            create: (context) => DashboardBloc(
              context.read<DashboardRepository>(),
              context.read<StrategyRepository>(),
            ),
          ),
          BlocProvider<PortfolioBloc>(
            create: (context) =>
                PortfolioBloc(context.read<PortfolioRepository>()),
          ),
          BlocProvider<StrategyBloc>(
            create: (context) => StrategyBloc(
              context.read<StrategyRepository>(),
              context.read<RiskManagementService>(),
              context.read<BacktestingService>(),
              context.read<TradingService>(),
            ),
          ),
          BlocProvider<TradeHistoryBloc>(
            create: (context) =>
                TradeHistoryBloc(context.read<TradeHistoryRepository>()),
          ),
          BlocProvider<SettingsBloc>(
            create: (context) =>
                SettingsBloc(context.read<SettingsRepository>()),
          ),
        ],
        child: child,
      ),
    );
  }

  void _initializeDatabase(DatabaseService databaseService) {
    databaseService.initDatabase().then((_) async {
      bool isHealthy = await databaseService.isDatabaseHealthy();
      if (isHealthy) {
        await databaseService.performMaintenance();
        await databaseService.checkAndCleanupOldData();
        await databaseService.optimizeDatabasePerformance();
      } else {
        await databaseService.backupDatabase();
      }
    }).catchError((error) {});
  }
}
