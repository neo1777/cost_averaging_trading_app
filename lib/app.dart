// lib/app.dart

import 'package:cost_averaging_trading_app/core/services/backtesting_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:cost_averaging_trading_app/core/theme/app_theme.dart';
import 'package:cost_averaging_trading_app/core/services/api_service.dart';
import 'package:cost_averaging_trading_app/core/services/database_service.dart';
import 'package:cost_averaging_trading_app/core/services/secure_storage_service.dart';
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
import 'package:cost_averaging_trading_app/routes.dart';
import 'package:cost_averaging_trading_app/ui/layouts/main_layout.dart';
import 'package:cost_averaging_trading_app/features/dashboard/ui/pages/dashboard_page.dart';

class App extends StatelessWidget {
  final ApiService apiService;
  final DatabaseService databaseService;
  final SecureStorageService secureStorageService;

  const App({
    super.key,
    required this.apiService,
    required this.databaseService,
    required this.secureStorageService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DashboardRepository>(
          create: (context) => DashboardRepository(
            apiService: apiService,
            databaseService: databaseService,
          ),
        ),
        RepositoryProvider<PortfolioRepository>(
          create: (context) => PortfolioRepository(
            apiService: apiService,
            databaseService: databaseService,
          ),
        ),
        RepositoryProvider<StrategyRepository>(
          create: (context) => StrategyRepository(
            apiService: apiService,
            databaseService: databaseService,
          ),
        ),
        RepositoryProvider<TradeHistoryRepository>(
          create: (context) => TradeHistoryRepository(),
        ),
        RepositoryProvider<SettingsRepository>(
          create: (context) => SettingsRepository(secureStorageService),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<DashboardBloc>(
            create: (context) =>
                DashboardBloc(context.read<DashboardRepository>()),
          ),
          BlocProvider<PortfolioBloc>(
            create: (context) =>
                PortfolioBloc(context.read<PortfolioRepository>()),
          ),
          BlocProvider<StrategyBloc>(
            create: (context) => StrategyBloc(
              context.read<StrategyRepository>(),
              context.read<SettingsRepository>(),
              context.read<BacktestingService>(),
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
        child: MaterialApp(
          title: 'Cost Averaging Trading App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: ResponsiveBuilder(
            builder: (context, sizingInformation) {
              return const MainLayout(
                child: DashboardPage(),
              );
            },
          ),
          onGenerateRoute: Routes.generateRoute,
        ),
      ),
    );
  }
}
