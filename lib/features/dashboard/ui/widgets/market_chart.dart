// lib/features/dashboard/ui/widgets/market_chart.dart

import 'package:cost_averaging_trading_app/candlestick/models/candle.dart';
import 'package:cost_averaging_trading_app/candlestick/models/candle_sticks_style.dart';
import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/candlestick/candlesticks.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/features/chart/blocs/chart_bloc.dart';
import 'package:cost_averaging_trading_app/features/chart/blocs/chart_event.dart';
import 'package:cost_averaging_trading_app/features/chart/blocs/chart_state.dart';
import 'package:cost_averaging_trading_app/core/services/api_service.dart';

class MarketChart extends StatelessWidget {
  final ApiService apiService;

  const MarketChart({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChartBloc, ChartState>(
      builder: (context, state) {
        if (state is ChartLoaded) {
          return Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Market Chart',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _buildSelectors(context, state),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _buildCandlestickChart(context, state),
                  ),
                ],
              ),
            ),
          );
        } else if (state is ChartLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ChartError) {
          return Center(child: Text(state.message));
        } else {
          return const Center(child: Text('Unknown state'));
        }
      },
    );
  }

  Widget _buildSelectors(BuildContext context, ChartLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDropdown(
          context,
          state.symbol,
          (String? newValue) {
            if (newValue != null) {
              context.read<ChartBloc>().add(ChangeSymbol(newValue));
            }
          },
          apiService.getPublicTradingSymbols(),
        ),
        _buildIntervalSelector(context, state),
      ],
    );
  }

  Widget _buildDropdown(BuildContext context, String currentValue,
      Function(String?) onChanged, Future<List<String>> itemsFuture) {
    return FutureBuilder<List<String>>(
      future: itemsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return DropdownButton<String>(
            value: currentValue,
            items: snapshot.data!.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Widget _buildIntervalSelector(BuildContext context, ChartLoaded state) {
    final intervals = [
      '1m',
      '3m',
      '5m',
      '15m',
      '30m',
      '1h',
      '2h',
      '4h',
      '6h',
      '8h',
      '12h',
      '1d',
      '3d',
      '1w',
      '1M'
    ];
    return DropdownButton<String>(
      value: state.interval,
      items: intervals.map((String value) {
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
    );
  }

  Widget _buildCandlestickChart(BuildContext context, ChartLoaded state) {
    final uniqueCandles = _removeDuplicates(state.candles);

    return Candlesticks(
      candles: uniqueCandles,
      onLoadMoreCandles: () async {
        final oldestCandle = uniqueCandles.last;
        final ChartBloc chartBloc = context.read<ChartBloc>();
        chartBloc.add(LoadMoreCandles(
          symbol: state.symbol,
          interval: state.interval,
          endTime: oldestCandle.date.millisecondsSinceEpoch,
        ));
        await Future.delayed(const Duration(seconds: 1));
      },
      style: CandleSticksStyle.dark(),
    );
  }

  List<Candle> _removeDuplicates(List<Candle> candles) {
    final uniqueCandles = <Candle>[];
    final seenDates = <DateTime>{};
    for (final candle in candles) {
      if (!seenDates.contains(candle.date)) {
        uniqueCandles.add(candle);
        seenDates.add(candle.date);
      }
    }
    return uniqueCandles;
  }
}
