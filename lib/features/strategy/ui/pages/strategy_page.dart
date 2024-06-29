import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cost_averaging_trading_app/core/widgets/shared_widgets.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_bloc.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_event.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_state.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/widgets/backtest_results.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/widgets/risk_info_card.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/widgets/strategy_chart.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/widgets/strategy_parameters_form.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/widgets/strategy_status.dart';
import 'package:cost_averaging_trading_app/ui/widgets/responsive_text.dart';

class StrategyPage extends StatelessWidget {
  const StrategyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StrategyBloc, StrategyState>(
      listener: (context, state) {
        if (state is StrategyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is StrategyInitial) {
          context.read<StrategyBloc>().add(LoadStrategyData());
          return const Center(child: CircularProgressIndicator());
        } else if (state is StrategyLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StrategyLoaded) {
          return _buildLoadedContent(context, state);
        } else if (state is StrategyError) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text('Unexpected state'));
      },
    );
  }

  Widget _buildLoadedContent(BuildContext context, StrategyLoaded state) {
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

  Widget _buildWideLayout(BuildContext context, StrategyLoaded state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText(
              'Strategy',
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
                        child: StrategyParametersForm(
                          initialParameters: state.parameters,
                          onParametersChanged: (parameters) {
                            context
                                .read<StrategyBloc>()
                                .add(UpdateStrategyParameters(parameters));
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomCard(
                        child: StrategyStatusWidget(
                          status: _mapStateStatusToWidgetStatus(state.status),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      CustomCard(
                        child: StrategyChart(chartData: state.chartData),
                      ),
                      const SizedBox(height: 16),
                      CustomCard(
                        child: RiskInfoCard(
                          maxLossPercentage:
                              state.riskManagementSettings.maxLossPercentage,
                          maxConcurrentTrades:
                              state.riskManagementSettings.maxConcurrentTrades,
                          maxPositionSizePercentage: state
                              .riskManagementSettings.maxPositionSizePercentage,
                          dailyExposureLimit:
                              state.riskManagementSettings.dailyExposureLimit,
                          maxAllowedVolatility:
                              state.riskManagementSettings.maxAllowedVolatility,
                          maxRebuyCount:
                              state.riskManagementSettings.maxRebuyCount,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: BacktestResults(
                backtestResult: state.backtestResult,
                onRunBacktest: (startDate, endDate) {
                  context.read<StrategyBloc>().add(
                        RunBacktestEvent(startDate, endDate),
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context, StrategyLoaded state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText(
              'Strategy',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: StrategyParametersForm(
                initialParameters: state.parameters,
                onParametersChanged: (parameters) {
                  context
                      .read<StrategyBloc>()
                      .add(UpdateStrategyParameters(parameters));
                },
              ),
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: StrategyStatusWidget(
                status: _mapStateStatusToWidgetStatus(state.status),
              ),
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: StrategyChart(chartData: state.chartData),
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: RiskInfoCard(
                maxLossPercentage:
                    state.riskManagementSettings.maxLossPercentage,
                maxConcurrentTrades:
                    state.riskManagementSettings.maxConcurrentTrades,
                maxPositionSizePercentage:
                    state.riskManagementSettings.maxPositionSizePercentage,
                dailyExposureLimit:
                    state.riskManagementSettings.dailyExposureLimit,
                maxAllowedVolatility:
                    state.riskManagementSettings.maxAllowedVolatility,
                maxRebuyCount: state.riskManagementSettings.maxRebuyCount,
              ),
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: BacktestResults(
                backtestResult: state.backtestResult,
                onRunBacktest: (startDate, endDate) {
                  context.read<StrategyBloc>().add(
                        RunBacktestEvent(startDate, endDate),
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  StrategyStatus _mapStateStatusToWidgetStatus(StrategyStateStatus status) {
    switch (status) {
      case StrategyStateStatus.active:
        return StrategyStatus.active;
      case StrategyStateStatus.paused:
        return StrategyStatus.paused;
      case StrategyStateStatus.inactive:
      default:
        return StrategyStatus.inactive;
    }
  }
}
