import 'package:cost_averaging_trading_app/candlestick/candlesticks.dart';
import 'package:cost_averaging_trading_app/candlestick/models/candle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_bloc.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_state.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_event.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/widgets/strategy_parameters_form.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/widgets/strategy_monitor.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/widgets/strategy_control_panel.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/widgets/backtest_result_view.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/widgets/strategy_status.dart';
import 'package:cost_averaging_trading_app/ui/layouts/custom_page_layout.dart';

class StrategyPage extends StatelessWidget {
  const StrategyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StrategyBloc, StrategyState>(
      builder: (context, state) {
        return CustomPageLayout(
          title: 'Strategy',
          useSliver: true,
          children: _buildStrategyContent(context, state),
        );
      },
    );
  }

  List<Widget> _buildStrategyContent(
      BuildContext context, StrategyState state) {
    if (state is StrategyInitial) {
      context.read<StrategyBloc>().add(LoadStrategyData());
      return [const Center(child: CircularProgressIndicator())];
    } else if (state is StrategyLoading) {
      return [const Center(child: CircularProgressIndicator())];
    } else if (state is StrategyLoaded) {
      return [
        _buildStrategyStatus(context, state),
        const SizedBox(height: 16),
        _buildStrategyParametersForm(context, state),
        const SizedBox(height: 16),
        _buildStrategyControlPanel(context, state),
        const SizedBox(height: 16),
        if (state.status == StrategyStateStatus.active)
          _buildStrategyMonitor(state),
        const SizedBox(height: 16),
        _buildCandlestickChart(state),
      ];
    } else if (state is BacktestCompleted) {
      return [BacktestResultView(result: state.result)];
    } else if (state is BacktestError) {
      return [Center(child: Text('Backtest Error: ${state.error}'))];
    } else if (state is StrategyError) {
      return [Center(child: Text('Strategy Error: ${state.message}'))];
    }
    return [const Center(child: Text('Unknown state'))];
  }

  Widget _buildCandlestickChart(StrategyLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Market Chart',
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 400,
              child: Candlesticks(
                candles: state.chartData
                    .map((data) => Candle(
                          date: data['date'],
                          high: data['high'],
                          low: data['low'],
                          open: data['open'],
                          close: data['close'],
                          volume: data['volume'],
                        ))
                    .toList(),
                onLoadMoreCandles: () async {
                  // Implementa la logica per caricare più candele
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategyStatus(BuildContext context, StrategyLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StrategyStatusWidget(
          status: state.status == StrategyStateStatus.active
              ? StrategyStatus.active
              : StrategyStatus.inactive,
          onStart: () => context.read<StrategyBloc>().add(StartStrategyEvent()),
          onStop: () => context.read<StrategyBloc>().add(StopStrategy()),
          onSellEntirePortfolio: () => context.read<StrategyBloc>().add(
                SellEntirePortfolio(
                  symbol: state.parameters.symbol,
                  targetProfit: state.parameters.targetProfitPercentage,
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildStrategyParametersForm(
      BuildContext context, StrategyLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StrategyParametersForm(
          initialParameters: state.parameters,
          onParametersChanged: (parameters) {
            context
                .read<StrategyBloc>()
                .add(UpdateStrategyParameters(parameters));
          },
        ),
      ),
    );
  }

  Widget _buildStrategyControlPanel(
      BuildContext context, StrategyLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StrategyControlPanel(
          isRunning: state.status == StrategyStateStatus.active,
          onStartLive: () =>
              context.read<StrategyBloc>().add(StartLiveStrategy()),
          onStartDemo: () =>
              context.read<StrategyBloc>().add(StartDemoStrategy()),
          onStop: () => context.read<StrategyBloc>().add(StopStrategy()),
          onBacktest: () => _showBacktestDialog(context),
        ),
      ),
    );
  }

  Widget _buildStrategyMonitor(StrategyLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StrategyMonitor(
          totalInvested: state.totalInvested,
          currentProfit: state.currentProfit,
          tradeCount: state.tradeCount,
          averageBuyPrice: state.averageBuyPrice,
          currentMarketPrice: state.currentMarketPrice,
          recentTrades: state.recentTrades,
        ),
      ),
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
