import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/features/portfolio/blocs/portfolio_bloc.dart';
import 'package:cost_averaging_trading_app/features/portfolio/blocs/portfolio_state.dart';
import 'package:cost_averaging_trading_app/features/portfolio/blocs/portfolio_event.dart';
import 'package:cost_averaging_trading_app/features/portfolio/ui/widgets/portfolio_summary.dart';
import 'package:cost_averaging_trading_app/features/portfolio/ui/widgets/portfolio_chart.dart';
import 'package:cost_averaging_trading_app/features/portfolio/ui/widgets/asset_list.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioBloc, PortfolioState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<PortfolioBloc>().add(LoadPortfolio());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Portfolio',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    _buildPortfolioContent(context, state),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPortfolioContent(BuildContext context, PortfolioState state) {
    if (state is PortfolioInitial) {
      context.read<PortfolioBloc>().add(LoadPortfolio());
      return const Center(child: CircularProgressIndicator());
    } else if (state is PortfolioLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is PortfolioLoaded) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildTile(
                  constraints,
                  PortfolioSummary(
                    totalValue: state.portfolio.totalValue,
                    dailyChange: state.dailyChange,
                    weeklyChange: state.weeklyChange,
                  )),
              _buildTile(constraints,
                  PortfolioChart(chartData: state.performanceData)),
              _buildTile(
                  constraints, AssetList(assets: state.portfolio.assets)),
            ],
          );
        },
      );
    } else if (state is PortfolioEmpty) {
      return const Center(
          child: Text('Il tuo portfolio è vuoto. Inizia a fare trading!'));
    } else if (state is PortfolioError) {
      return Center(child: Text(state.message));
    }
    return const Center(child: Text('Stato sconosciuto'));
  }

  Widget _buildTile(BoxConstraints constraints, Widget child) {
    double width = constraints.maxWidth > 600
        ? (constraints.maxWidth - 16) / 2
        : constraints.maxWidth;
    return SizedBox(
      width: width,
      child: child,
    );
  }
}
