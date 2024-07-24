import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/features/portfolio/blocs/portfolio_bloc.dart';
import 'package:cost_averaging_trading_app/features/portfolio/blocs/portfolio_state.dart';
import 'package:cost_averaging_trading_app/features/portfolio/blocs/portfolio_event.dart';
import 'package:cost_averaging_trading_app/features/portfolio/ui/widgets/asset_list.dart';
import 'package:cost_averaging_trading_app/features/portfolio/ui/widgets/portfolio_summary.dart';
import 'package:cost_averaging_trading_app/features/portfolio/ui/widgets/portfolio_chart.dart';
import 'package:cost_averaging_trading_app/ui/layouts/custom_page_layout.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioBloc, PortfolioState>(
      builder: (context, state) {
        return CustomPageLayout(
          title: 'Portfolio',
          useSliver: true,
          children: _buildPortfolioContent(context, state),
        );
      },
    );
  }

  List<Widget> _buildPortfolioContent(
      BuildContext context, PortfolioState state) {
    if (state is PortfolioInitial) {
      context.read<PortfolioBloc>().add(LoadPortfolio());
      return [const Center(child: CircularProgressIndicator())];
    } else if (state is PortfolioLoading) {
      return [const Center(child: CircularProgressIndicator())];
    } else if (state is PortfolioLoaded) {
      return [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: PortfolioSummary(totalValue: state.portfolio.totalValue),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: PortfolioChart(chartData: state.performanceData),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AssetList(assets: state.portfolio.assets),
          ),
        ),
      ];
    } else if (state is PortfolioError) {
      return [Center(child: Text('Error: ${state.message}'))];
    }
    return [const Center(child: Text('Unknown state'))];
  }
}
