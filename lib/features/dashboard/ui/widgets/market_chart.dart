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

  MarketChart({Key? key, required this.apiService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChartBloc, ChartState>(
      builder: (context, state) {
        if (state is ChartLoaded) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildSelectors(context, state),
                _buildCandlestickChart(context, state),
              ],
            ),
          );
        } else if (state is ChartLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ChartError) {
          return Center(
              child:
                  Text(state.message, style: TextStyle(color: Colors.white)));
        } else {
          return const Center(
              child:
                  Text('Unknown state', style: TextStyle(color: Colors.white)));
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
                child: Text(value, style: TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: onChanged,
            style: TextStyle(color: Colors.white),
            dropdownColor: Colors.grey[900],
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}',
              style: TextStyle(color: Colors.white));
        }
        return CircularProgressIndicator();
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
          child: Text(value, style: TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          context.read<ChartBloc>().add(ChangeInterval(newValue));
        }
      },
      style: TextStyle(color: Colors.white),
      dropdownColor: Colors.grey[900],
    );
  }

  Widget _buildCandlestickChart(BuildContext context, ChartLoaded state) {
    // Rimuovi eventuali duplicati dai dati delle candele
    final uniqueCandles = _removeDuplicates(state.candles);

    return Container(
      height: 400,
      child: Candlesticks(
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
      ),
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
