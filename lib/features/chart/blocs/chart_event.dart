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

class ChangeSymbol extends ChartEvent {
  final String symbol;

  const ChangeSymbol(this.symbol);

  @override
  List<Object> get props => [symbol];
}

class ToggleOrderMarkers extends ChartEvent {}

class UpdateTicker extends ChartEvent {
  final Map<String, dynamic> tickerData;
  const UpdateTicker(this.tickerData);

  @override
  List<Object> get props => [tickerData];
}

class ZoomIn extends ChartEvent {}

class ZoomOut extends ChartEvent {}

class ResetZoom extends ChartEvent {}

class PanLeft extends ChartEvent {}

class PanRight extends ChartEvent {}

class ToggleVolume extends ChartEvent {}

class ToggleFullScreen extends ChartEvent {}

class AddIndicator extends ChartEvent {
  final String indicatorType;
  final Map<String, dynamic> parameters;

  const AddIndicator(this.indicatorType, this.parameters);

  @override
  List<Object> get props => [indicatorType, parameters];
}

class RemoveIndicator extends ChartEvent {
  final String indicatorId;

  const RemoveIndicator(this.indicatorId);

  @override
  List<Object> get props => [indicatorId];
}

class UpdateIndicatorSettings extends ChartEvent {
  final String indicatorId;
  final Map<String, dynamic> newSettings;

  const UpdateIndicatorSettings(this.indicatorId, this.newSettings);

  @override
  List<Object> get props => [indicatorId, newSettings];
}

class LoadMoreCandles extends ChartEvent {
  final String symbol;
  final String interval;
  final int endTime;

  const LoadMoreCandles({
    required this.symbol,
    required this.interval,
    required this.endTime,
  });

  @override
  List<Object> get props => [symbol, interval, endTime];
}
