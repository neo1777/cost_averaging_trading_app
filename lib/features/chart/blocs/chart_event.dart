import 'package:cost_averaging_trading_app/candlestick/models/candle.dart';
import 'package:equatable/equatable.dart';

abstract class ChartEvent extends Equatable {
  const ChartEvent();

  @override
  List<Object> get props => [];
}

class LoadChartData extends ChartEvent {}

class UpdateChartData extends ChartEvent {
  final Candle latestCandle;

  const UpdateChartData({required this.latestCandle});

  @override
  List<Object> get props => [latestCandle];
}

class ChangeInterval extends ChartEvent {
  final String interval;

  const ChangeInterval(this.interval);

  @override
  List<Object> get props => [interval];
}

class ToggleOrderMarkers extends ChartEvent {}

class UpdateTicker extends ChartEvent {
  final Map<String, dynamic> tickerData;
  const UpdateTicker(this.tickerData);

  @override
  List<Object> get props => [tickerData];
}