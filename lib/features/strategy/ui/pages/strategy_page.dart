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
        } else if (state is StrategyUnsafe) {
          _showUnsafeStrategyDialog(context, state);
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
                          onStart: () =>
                              _showStartStrategyDialog(context, state),
                          onStop: () =>
                              context.read<StrategyBloc>().add(StopStrategy()),
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
                onStart: () => _showStartStrategyDialog(context, state),
                onStop: () => context.read<StrategyBloc>().add(StopStrategy()),
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

  void _showStartStrategyDialog(BuildContext context, StrategyLoaded state) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Start Strategy'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Choose a mode to start the strategy:'),
              const SizedBox(height: 16),
              ElevatedButton(
                child: const Text('Backtesting'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _showBacktestDialog(context);
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                child: const Text('Demo Mode'),
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<StrategyBloc>().add(StartDemoStrategy());
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                child: const Text('Live Mode'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _showLiveConfirmationDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBacktestDialog(BuildContext context) {
    DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
    DateTime endDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Run Backtest'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select date range for backtesting:'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          child: Text(
                              'Start: ${startDate.toLocal().toString().split(' ')[0]}'),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null && picked != startDate) {
                              setState(() {
                                startDate = picked;
                              });
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          child: Text(
                              'End: ${endDate.toLocal().toString().split(' ')[0]}'),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: endDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null && picked != endDate) {
                              setState(() {
                                endDate = picked;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Run Backtest'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    context
                        .read<StrategyBloc>()
                        .add(RunBacktestEvent(startDate, endDate));
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLiveConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Live Mode'),
          content: const Text(
              'Are you sure you want to start the strategy in live mode? This will use real funds.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                _showFinalLiveConfirmation(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showFinalLiveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Final Confirmation'),
          content: const Text(
              'This is your final confirmation. The strategy will start in live mode using real funds. Are you absolutely sure?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Start Live Mode'),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<StrategyBloc>().add(StartLiveStrategy());
              },
            ),
          ],
        );
      },
    );
  }

  void _showUnsafeStrategyDialog(BuildContext context, StrategyUnsafe state) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Strategy Risk Warning'),
          content: Text(state.message),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Start Anyway'),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<StrategyBloc>().add(ForceStartStrategy());
              },
            ),
          ],
        );
      },
    );
  }
}
