import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_bloc.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_state.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/widgets/strategy_parameters_form.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/widgets/strategy_chart.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/widgets/strategy_monitor.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/widgets/backtest_results.dart';

class StrategyPage extends StatelessWidget {
  const StrategyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StrategyBloc, StrategyState>(
      builder: (context, state) {
        // Log per debug
        if (state is StrategyInitial || state is StrategyLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StrategyLoaded) {
          return _buildLoadedContent(context, state);
        } else if (state is StrategyError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        // Gestione dello stato sconosciuto
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Unknown state: $state'),
              ElevatedButton(
                onPressed: () =>
                    context.read<StrategyBloc>().add(LoadStrategyData()),
                child: const Text('Reload Data'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadedContent(BuildContext context, StrategyLoaded state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Strategy', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            StrategyParametersForm(
              initialParameters: state.parameters,
              onParametersChanged: (parameters) {
                context
                    .read<StrategyBloc>()
                    .add(UpdateStrategyParameters(parameters));
              },
            ),
            const SizedBox(height: 16),
            StrategyChart(chartData: state.chartData),
            const SizedBox(height: 16),
            StrategyMonitor(
              totalInvested: state.totalInvested,
              currentProfit: state.currentProfit,
              tradeCount: state.tradeCount,
              averageBuyPrice: state.averageBuyPrice,
              currentMarketPrice: state.currentMarketPrice,
              recentTrades: state.recentTrades,
            ),
            if (state.backtestResult != null) ...[
              const SizedBox(height: 16),
              BacktestResults(
                backtestResult: state.backtestResult!,
                onRunBacktest: (startDate, endDate) {
                  context
                      .read<StrategyBloc>()
                      .add(RunBacktestEvent(startDate, endDate));
                },
              ),
            ],
          ],
        ),
      ),
    );
  }









}
