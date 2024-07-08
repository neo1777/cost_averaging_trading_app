import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_event.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/widgets/backtest_progress_chart.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/widgets/backtest_result_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_bloc.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_state.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/widgets/strategy_parameters_form.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/widgets/strategy_monitor.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/widgets/strategy_control_panel.dart';

class StrategyPage extends StatelessWidget {
  const StrategyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StrategyBloc, StrategyState>(
      builder: (context, state) {
        if (state is StrategyLoaded) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Strategy Configuration',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  StrategyParametersForm(
                    initialParameters: state.parameters,
                    onParametersChanged: (parameters) {
                      context
                          .read<StrategyBloc>()
                          .add(UpdateStrategyParameters(parameters));
                    },
                  ),
                  const SizedBox(height: 24),
                  StrategyControlPanel(
                    isRunning: state.status == StrategyStateStatus.active,
                    onStartLive: () =>
                        context.read<StrategyBloc>().add(StartLiveStrategy()),
                    onStartDemo: () =>
                        context.read<StrategyBloc>().add(StartDemoStrategy()),
                    onStop: () =>
                        context.read<StrategyBloc>().add(StopStrategy()),
                    onBacktest: () => _showBacktestDialog(context),
                  ),
                  if (state.status == StrategyStateStatus.active)
                    StrategyMonitor(
                      totalInvested: state.totalInvested,
                      currentProfit: state.currentProfit,
                      tradeCount: state.tradeCount,
                      averageBuyPrice: state.averageBuyPrice,
                      currentMarketPrice: state.currentMarketPrice,
                      recentTrades: state.recentTrades,
                    ),
                ],
              ),
            ),
          );
        } else if (state is BacktestInProgress) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Running Backtest...'),
              ],
            ),
          );
        } else if (state is BacktestCompleted) {
          return BacktestResultView(result: state.result);
        } else if (state is BacktestError) {
          return Center(child: Text('Backtest Error: ${state.error}'));
        } else if (state is BacktestProgressUpdate) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(value: state.progress),
                const SizedBox(height: 16),
                Text(
                    'Running Backtest: ${(state.progress * 100).toStringAsFixed(1)}%'),
                const SizedBox(height: 16),
                BacktestProgressChart(
                  spots: state.currentInvestmentOverTime
                      .asMap()
                      .entries
                      .map((entry) =>
                          FlSpot(entry.key.toDouble(), entry.value['value']))
                      .toList(),
                  minY: state.currentInvestmentOverTime
                      .map((e) => e['value'] as double)
                      .reduce((a, b) => a < b ? a : b),
                  maxY: state.currentInvestmentOverTime
                      .map((e) => e['value'] as double)
                      .reduce((a, b) => a > b ? a : b),
                ),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _showBacktestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Run Backtest'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select backtest period:'),
              ElevatedButton(
                child: const Text('Last 30 days'),
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<StrategyBloc>().add(RunBacktestEvent(
                        DateTime.now().subtract(const Duration(days: 30)),
                        DateTime.now(),
                      ));
                },
              ),
              ElevatedButton(
                child: const Text('Last 90 days'),
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<StrategyBloc>().add(RunBacktestEvent(
                        DateTime.now().subtract(const Duration(days: 90)),
                        DateTime.now(),
                      ));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
