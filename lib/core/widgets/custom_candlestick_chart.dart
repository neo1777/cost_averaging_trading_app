import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
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
    return BlocConsumer<ChartBloc, ChartState>(
      bloc: _chartBloc,
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
    );
  }

  Widget _buildChart(BuildContext context, ChartLoaded state) {
    final validCandles =
        state.candles.where((candle) => candle.low != null).toList();

    if (validCandles.isEmpty) {
      return const Center(child: Text('No valid candle data available'));
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: _createBarGroups(validCandles),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: _bottomTitles(),
            leftTitles: _leftTitles(),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[300],
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey[300],
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups(List<Candle> candles) {
    return candles.asMap().entries.map((entry) {
      final index = entry.key;
      final candle = entry.value;
      final open = candle.open;
      final close = candle.close;
      final high = candle.high;
      final low = candle.low;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: high,
            fromY: low,
            color: open > close ? Colors.red : Colors.green,
            width: 8,
          ),
        ],
      );
    }).toList();
  }

  AxisTitles _bottomTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          final index = value.toInt();
          if (index % 5 == 0) {
            return Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.black, fontSize: 10),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  AxisTitles _leftTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          return Text(
            value.toStringAsFixed(2),
            style: const TextStyle(color: Colors.black, fontSize: 10),
          );
        },
      ),
    );
  }
}
