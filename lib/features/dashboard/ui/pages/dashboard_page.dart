// lib/features/dashboard/ui/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/features/dashboard/blocs/dashboard_bloc.dart';
import 'package:cost_averaging_trading_app/features/dashboard/blocs/dashboard_state.dart';
import 'package:cost_averaging_trading_app/features/dashboard/blocs/dashboard_event.dart';
import 'package:cost_averaging_trading_app/features/dashboard/ui/widgets/portfolio_overview.dart';
import 'package:cost_averaging_trading_app/features/dashboard/ui/widgets/performance_chart.dart';
import 'package:cost_averaging_trading_app/features/dashboard/ui/widgets/recent_trades_widget.dart';
import 'package:cost_averaging_trading_app/core/widgets/custom_candlestick_chart.dart';
import 'package:cost_averaging_trading_app/ui/layouts/custom_page_layout.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardInitial) {
          context.read<DashboardBloc>().add(LoadDashboardData());
        }
        return CustomPageLayout(
          title: 'Dashboard',
          useSliver: true,
          children: _buildDashboardContent(context, state),
        );
      },
    );
  }

  List<Widget> _buildDashboardContent(
      BuildContext context, DashboardState state) {
    if (state is DashboardLoading) {
      return [const Center(child: CircularProgressIndicator())];
    } else if (state is DashboardLoaded) {
      return [
        _buildOverviewSection(state),
        _buildChartSection(state),
        _buildRecentTradesSection(context, state),
        _buildPerformanceSection(state),
      ];
    } else if (state is DashboardError) {
      return [Center(child: Text('Error: ${state.message}'))];
    }
    return [const Center(child: Text('Unknown state'))];
  }

  Widget _buildOverviewSection(DashboardLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PortfolioOverview(portfolio: state.portfolio),
      ),
    );
  }

  Widget _buildChartSection(DashboardLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Market Chart',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: CustomCandlestickChart(
                symbol: state.activeStrategy?.symbol ?? 'BTCUSDT',
                trades: state.recentTrades,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTradesSection(
      BuildContext context, DashboardLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RecentTradesWidget(
          trades: state.recentTrades,
          currentPage: state.currentPage,
          tradesPerPage: state.tradesPerPage,
          onPageChanged: (newPage) {
            context.read<DashboardBloc>().add(ChangePage(newPage));
          },
          onChangeTradesPerPage: (newValue) {
            context.read<DashboardBloc>().add(ChangeTradesPerPage(newValue));
          },
        ),
      ),
    );
  }

  Widget _buildPerformanceSection(DashboardLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PerformanceChart(performanceData: state.performanceData),
      ),
    );
  }
}
