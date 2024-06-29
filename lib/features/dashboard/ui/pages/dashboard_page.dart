// lib/features/dashboard/ui/pages/dashboard_page.dart

import 'package:cost_averaging_trading_app/features/dashboard/blocs/dashboard_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/core/widgets/shared_widgets.dart';
import 'package:cost_averaging_trading_app/features/dashboard/blocs/dashboard_bloc.dart';
import 'package:cost_averaging_trading_app/features/dashboard/blocs/dashboard_state.dart';
import 'package:cost_averaging_trading_app/features/dashboard/ui/widgets/portfolio_overview.dart';
import 'package:cost_averaging_trading_app/features/dashboard/ui/widgets/performance_chart.dart';
import 'package:cost_averaging_trading_app/features/dashboard/ui/widgets/recent_trades_widget.dart';
import 'package:cost_averaging_trading_app/ui/widgets/responsive_text.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is DashboardError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is DashboardInitial) {
          context.read<DashboardBloc>().add(LoadDashboardData());
          return const LoadingIndicator(message: 'Loading dashboard...');
        } else if (state is DashboardLoading) {
          return const LoadingIndicator(message: 'Updating dashboard...');
        } else if (state is DashboardLoaded) {
          return _buildLoadedContent(context, state);
        } else if (state is DashboardError) {
          return ErrorMessage(message: state.message);
        }
        return const ErrorMessage(message: 'Unknown state');
      },
    );
  }

  Widget _buildLoadedContent(BuildContext context, DashboardLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return _buildWideLayout(context, state);
        } else {
          return _buildNarrowLayout(context, state);
        }
      },
    );
  }

  Widget _buildWideLayout(BuildContext context, DashboardLoaded state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: CustomCard(
                    child: PortfolioOverview(portfolio: state.portfolio),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: CustomCard(
                    child: PerformanceChart(
                      performanceData: state.performanceData,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: RecentTradesWidget(trades: state.recentTrades),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context, DashboardLoaded state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: PortfolioOverview(portfolio: state.portfolio),
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: PerformanceChart(
                performanceData: state.performanceData,
              ),
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: RecentTradesWidget(trades: state.recentTrades),
            ),
          ],
        ),
      ),
    );
  }
}
