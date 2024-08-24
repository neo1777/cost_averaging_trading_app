// lib/features/strategy/ui/widgets/market_chart.dart

import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/candlestick/candlesticks.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/features/chart/blocs/chart_bloc.dart';
import 'package:cost_averaging_trading_app/features/chart/blocs/chart_event.dart';
import 'package:cost_averaging_trading_app/features/chart/blocs/chart_state.dart';

class MarketChart extends StatelessWidget {
  final String symbol;

  const MarketChart({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChartBloc, ChartState>(
      builder: (context, state) {
        if (state is ChartLoaded) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Market Chart',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _buildSelectors(context, state),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400,
                    child: Candlesticks(
                      candles: state.candles,
                      onLoadMoreCandles: () async {
                        context.read<ChartBloc>().add(LoadMoreCandles(
                              symbol: state.symbol,
                              interval: state.interval,
                              endTime: state
                                  .candles.last.date.millisecondsSinceEpoch,
                            ));
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is ChartLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ChartError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const Center(child: Text('Unknown state'));
      },
    );
  }

  Widget _buildSelectors(BuildContext context, ChartLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DropdownButton<String>(
          value: state.interval,
          items:
              ['1m', '5m', '15m', '30m', '1h', '4h', '1d'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              context.read<ChartBloc>().add(ChangeInterval(newValue));
            }
          },
        ),
      ],
    );
  }
}
