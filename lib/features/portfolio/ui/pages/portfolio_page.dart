import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/core/widgets/shared_widgets.dart';
import 'package:cost_averaging_trading_app/features/portfolio/blocs/portfolio_bloc.dart';
import 'package:cost_averaging_trading_app/features/portfolio/blocs/portfolio_event.dart';
import 'package:cost_averaging_trading_app/features/portfolio/blocs/portfolio_state.dart';
import 'package:cost_averaging_trading_app/features/portfolio/ui/widgets/asset_list.dart';
import 'package:cost_averaging_trading_app/features/portfolio/ui/widgets/portfolio_summary.dart';
import 'package:cost_averaging_trading_app/features/portfolio/ui/widgets/portfolio_chart.dart';
import 'package:cost_averaging_trading_app/ui/widgets/responsive_text.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PortfolioBloc, PortfolioState>(
      listener: (context, state) {
        if (state is PortfolioError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is PortfolioInitial) {
          context.read<PortfolioBloc>().add(LoadPortfolio());
          return const LoadingIndicator(message: 'Loading portfolio...');
        } else if (state is PortfolioLoading) {
          return const LoadingIndicator(message: 'Updating portfolio...');
        } else if (state is PortfolioLoaded) {
          return _buildLoadedContent(context, state);
        } else if (state is PortfolioError) {
          return ErrorMessage(message: state.message);
        }
        return const ErrorMessage(message: 'Unknown state');
      },
    );
  }

  Widget _buildLoadedContent(BuildContext context, PortfolioLoaded state) {
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

  Widget _buildWideLayout(BuildContext context, PortfolioLoaded state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText(
              'Portfolio',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      CustomCard(
                        child: PortfolioSummary(
                            totalValue: state.portfolio.totalValue),
                      ),
                      const SizedBox(height: 16),
                      CustomCard(
                        child: AssetList(assets: state.portfolio.assets),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: CustomCard(
                    child: PortfolioChart(chartData: state.performanceData),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context, PortfolioLoaded state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText(
              'Portfolio',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: PortfolioSummary(totalValue: state.portfolio.totalValue),
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: PortfolioChart(chartData: state.performanceData),
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: AssetList(assets: state.portfolio.assets),
            ),
          ],
        ),
      ),
    );
  }
}