import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/features/dashboard/blocs/dashboard_bloc.dart';
import 'package:cost_averaging_trading_app/features/dashboard/blocs/dashboard_state.dart';
import 'package:cost_averaging_trading_app/features/dashboard/blocs/dashboard_event.dart';
import 'package:cost_averaging_trading_app/features/dashboard/ui/widgets/portfolio_overview.dart';
import 'package:cost_averaging_trading_app/features/dashboard/ui/widgets/market_chart.dart';
import 'package:cost_averaging_trading_app/features/dashboard/ui/widgets/recent_trades_widget.dart';
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
        _buildPortfolioOverview(context, state),
        const SizedBox(height: 16),
        _buildMarketChart(context, state),
        const SizedBox(height: 16),
        _buildRecentTrades(context, state),
      ];
    } else if (state is DashboardError) {
      return [Center(child: Text('Error: ${state.message}'))];
    }
    return [const Center(child: Text('Unknown state'))];
  }

  Widget _buildPortfolioOverview(BuildContext context, DashboardLoaded state) {
    return Card(
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Market Chart', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: MarketChart(
                candles: state.marketData,
                symbol: state.selectedSymbol,
                onSymbolChanged: (String symbol) {
                  context.read<DashboardBloc>().add(ChangeSymbol(symbol));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTrades(BuildContext context, DashboardLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RecentTradesWidget(
          trades: state.recentTrades,
          onViewAllTrades: () {
            Navigator.pushNamed(context, '/trade-history');
          },
        ),
      ),
    );
  }
}
