// lib/features/strategy/ui/pages/strategy_page.dart

import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_bloc.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_state.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/widgets/strategy_status.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/widgets/strategy_parameters_form.dart';
import 'package:cost_averaging_trading_app/features/strategy/ui/widgets/strategy_control_panel.dart';

class StrategyPage extends StatelessWidget {
  const StrategyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: BlocBuilder<StrategyBloc, StrategyState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Strategy',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  if (state is StrategyLoaded)
                    _buildStrategyContent(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStrategyContent(BuildContext context, StrategyLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildTile(
                constraints,
                StrategyStatusWidget(
                  status: state.status == StrategyStateStatus.active
                      ? StrategyStatus.active
                      : StrategyStatus.inactive,
                  onStart: () =>
                      context.read<StrategyBloc>().add(StartStrategyEvent()),
                  onStop: () =>
                      context.read<StrategyBloc>().add(StopStrategy()),
                  onSellEntirePortfolio: () => context.read<StrategyBloc>().add(
                        SellEntirePortfolio(
                          symbol: state.parameters.symbol,
                          targetProfit: state.parameters.targetProfitPercentage,
                        ),
                      ),
                )),
            _buildTile(
                constraints,
                StrategyParametersForm(
                  initialParameters: state.parameters,
                  onParametersChanged: (parameters) {
                    context
                        .read<StrategyBloc>()
                        .add(UpdateStrategyParameters(parameters));
                  },
                )),
            _buildTile(
                constraints,
                StrategyControlPanel(
                  isRunning: state.status == StrategyStateStatus.active,
                  onStartLive: () =>
                      context.read<StrategyBloc>().add(StartLiveStrategy()),
                  onStartDemo: () =>
                      context.read<StrategyBloc>().add(StartDemoStrategy()),
                  onStop: () =>
                      context.read<StrategyBloc>().add(StopStrategy()),
                  onBacktest: () => _showBacktestDialog(context),
                )),
          ],
        );
      },
    );
  }

  Widget _buildTile(BoxConstraints constraints, Widget child) {
    double width = constraints.maxWidth > 600
        ? (constraints.maxWidth - 32) / 2
        : constraints.maxWidth;
    return SizedBox(
      width: width,
      child: child,
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
