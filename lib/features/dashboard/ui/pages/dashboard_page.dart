// lib/features/dashboard/ui/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/features/dashboard/blocs/dashboard_bloc.dart';
import 'package:cost_averaging_trading_app/features/dashboard/blocs/dashboard_state.dart';
import 'package:cost_averaging_trading_app/features/dashboard/blocs/dashboard_event.dart';
import 'package:cost_averaging_trading_app/features/dashboard/ui/widgets/portfolio_overview.dart';
import 'package:cost_averaging_trading_app/features/dashboard/ui/widgets/market_chart.dart';
import 'package:cost_averaging_trading_app/features/dashboard/ui/widgets/recent_trades_widget.dart';
import 'package:cost_averaging_trading_app/core/services/api_service.dart';

class DashboardPage extends StatelessWidget {
  final ApiService publicApiService = ApiService.public();

  DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardInitial) {
          context.read<DashboardBloc>().add(LoadDashboardData());
        }
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: _buildDashboardContent(context, state),
        );
      },
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardState state) {
    if (state is DashboardLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is DashboardLoaded) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              _buildGridLayout(context, state),
            ],
          ),
        ),
      );
    } else if (state is DashboardError) {
      return Center(child: Text('Error: ${state.message}'));
    }
    return const Center(child: Text('Unknown state'));
  }

  Widget _buildGridLayout(BuildContext context, DashboardLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          children: [
            _buildPortfolioOverview(context, state),
            _buildMarketChart(context, state),
            _buildRecentTrades(context, state),
          ],
        );
      },
    );
  }

  Widget _buildPortfolioOverview(BuildContext context, DashboardLoaded state) {
    return PortfolioOverview(
      totalValue: state.portfolio.totalValue,
      dailyChange: state.dailyChange,
      assets: state.portfolio.assets,
    );
  }

  Widget _buildMarketChart(BuildContext context, DashboardLoaded state) {
    return MarketChart(apiService: publicApiService);
  }

  Widget _buildRecentTrades(BuildContext context, DashboardLoaded state) {
    return RecentTradesWidget(
      trades: state.recentTrades,
      onViewAllTrades: () {
        Navigator.pushNamed(context, '/trade-history');
      },
    );
  }
}
