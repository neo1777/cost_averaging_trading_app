// lib/features/chart/blocs/chart_state.dart

import 'package:equatable/equatable.dart';
import 'package:candlesticks/candlesticks.dart';

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

  const ChartLoaded({
    required this.candles,
    required this.interval,
    required this.showOrderMarkers,
  });

  @override
  List<Object> get props => [candles, interval, showOrderMarkers];
}

class ChartError extends ChartState {
  final String message;

  const ChartError({required this.message});

  @override
  List<Object> get props => [message];
}
