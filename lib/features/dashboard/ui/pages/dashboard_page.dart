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
          backgroundColor: Colors.black,
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
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              _buildPortfolioOverview(context, state),
              SizedBox(height: 16),
              _buildMarketChart(context, state),
              SizedBox(height: 16),
              _buildRecentTrades(context, state),
            ],
          ),
        ),
      );
    } else if (state is DashboardError) {
      return Center(
          child: Text('Error: ${state.message}',
              style: TextStyle(color: Colors.white)));
    }
    return Center(
        child: Text('Unknown state', style: TextStyle(color: Colors.white)));
  }

  Widget _buildPortfolioOverview(BuildContext context, DashboardLoaded state) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PortfolioOverview(
          totalValue: state.portfolio.totalValue,
          dailyChange: state.dailyChange,
          assets: state.portfolio.assets,
        ),
      ),
    );
  }

  Widget _buildMarketChart(BuildContext context, DashboardLoaded state) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Market Chart',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Container(
              height: 400,
              child: MarketChart(apiService: publicApiService),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTrades(BuildContext context, DashboardLoaded state) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Trades',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Container(
              height: 200,
              child: RecentTradesWidget(
                trades: state.recentTrades,
                onViewAllTrades: () {
                  Navigator.pushNamed(context, '/trade-history');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
