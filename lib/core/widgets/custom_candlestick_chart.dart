import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:cost_averaging_trading_app/features/chart/blocs/chart_bloc.dart';
import 'package:cost_averaging_trading_app/features/chart/blocs/chart_event.dart';
import 'package:cost_averaging_trading_app/features/chart/blocs/chart_state.dart';
import 'package:cost_averaging_trading_app/core/models/trade.dart';
import 'package:cost_averaging_trading_app/core/services/api_service.dart';

class CustomCandlestickChart extends StatefulWidget {
  final String symbol;
  final List<CoreTrade> trades;

  const CustomCandlestickChart({
    super.key,
    required this.symbol,
    required this.trades,
  });

  @override
  CustomCandlestickChartState createState() => CustomCandlestickChartState();
}

class CustomCandlestickChartState extends State<CustomCandlestickChart> {
  late ChartBloc _chartBloc;

  @override
  void initState() {
    super.initState();
    _chartBloc = ChartBloc(
      symbol: widget.symbol,
      apiService: context.read<ApiService>(),
    );
    _chartBloc.add(LoadChartData());
  }

  @override
  void dispose() {
    _chartBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chartBloc,
      child: BlocConsumer<ChartBloc, ChartState>(
        listener: (context, state) {
          if (state is ChartError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ChartLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChartLoaded && state.candles.isNotEmpty) {
            return _buildChart(context, state);
          } else if (state is ChartError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildChart(BuildContext context, ChartLoaded state) {
    if (state.candles.isEmpty) {
      return const Center(child: Text('No candle data available'));
    }
    return Stack(
      children: [
        Candlesticks(
          candles: state.candles,
          actions: [
            ToolBarAction(
              onPressed: () => _chartBloc.add(ToggleOrderMarkers()),
              child: Icon(
                state.showOrderMarkers
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
            ),
            ToolBarAction(
              onPressed: () => _showIntervalPicker(context),
              child: const Text('Interval'),
            ),
          ],
        ),
        Positioned(
          top: 10,
          right: 10,
          child: _buildIntervalMenu(context),
        ),
        if (state.showOrderMarkers) ..._buildOrderMarkers(context, state),
      ],
    );
  }

  Widget _buildIntervalMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (String newInterval) {
        _chartBloc.add(ChangeInterval(newInterval));
      },
      itemBuilder: (BuildContext context) {
        return ChartBloc.intervals.map((String interval) {
          return PopupMenuItem<String>(
            value: interval,
            child: Text(interval),
          );
        }).toList();
      },
    );
  }

  void _showIntervalPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Interval'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ChartBloc.intervals
                .map((interval) => ListTile(
                      title: Text(interval),
                      onTap: () {
                        Navigator.of(context).pop();
                        _chartBloc.add(ChangeInterval(interval));
                      },
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  List<Widget> _buildOrderMarkers(BuildContext context, ChartLoaded state) {
    return widget.trades.map((trade) {
      final index = state.candles
          .indexWhere((candle) => candle.date.isAfter(trade.timestamp));
      if (index == -1) return const SizedBox.shrink();

      final x = index / state.candles.length;
      final y = (trade.price - state.candles[index].low) /
          (state.candles[index].high - state.candles[index].low);

      return Positioned(
        left: x * MediaQuery.of(context).size.width,
        top: y * MediaQuery.of(context).size.height,
        child: Icon(
          trade.type == CoreTradeType.buy
              ? Icons.arrow_upward
              : Icons.arrow_downward,
          color: trade.type == CoreTradeType.buy ? Colors.green : Colors.red,
          size: 16,
        ),
      );
    }).toList();
  }
}
