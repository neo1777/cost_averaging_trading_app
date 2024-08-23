import 'package:cost_averaging_trading_app/candlestick/models/candle.dart';
import 'package:equatable/equatable.dart';

abstract class ChartState extends Equatable {
  const ChartState();

  @override
  List<Object> get props => [];
}

class ChartLoading extends ChartState {}

class ChartLoaded extends ChartState {
  final List<Candle> candles;
  final String interval;
  final bool showOrderMarkers;
  final String symbol;

  const ChartLoaded({
    required this.candles,
    required this.interval,
    required this.showOrderMarkers,
    required this.symbol,
  });

  @override
  List<Object> get props => [candles, interval, showOrderMarkers, symbol];
}

class ChartError extends ChartState {
  final String message;

  const ChartError({required this.message});

  @override
  List<Object> get props => [message];
}
