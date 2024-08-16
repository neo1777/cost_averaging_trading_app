import 'dart:async';
import 'package:candlesticks/candlesticks.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/core/services/api_service.dart';
import 'package:cost_averaging_trading_app/features/chart/blocs/chart_event.dart';
import 'package:cost_averaging_trading_app/features/chart/blocs/chart_state.dart';

class ChartBloc extends Bloc<ChartEvent, ChartState> {
  final ApiService _apiService;
  final String symbol;
  StreamSubscription<Map<String, dynamic>>? _klineSubscription;
  static const List<String> intervals = [
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

  ChartBloc({required this.symbol, required ApiService apiService})
      : _apiService = apiService,
        super(ChartLoading()) {
    on<LoadChartData>(_onLoadChartData);
    on<UpdateChartData>(_onUpdateChartData);
    on<ChangeInterval>(_onChangeInterval);
    on<ToggleOrderMarkers>(_onToggleOrderMarkers);
  }

  Future<void> _onLoadChartData(
      LoadChartData event, Emitter<ChartState> emit) async {
    try {
      emit(ChartLoading());
      final candles = await _fetchInitialCandles();
      _subscribeToKlineUpdates('1m');
      emit(ChartLoaded(
          candles: candles, interval: '1m', showOrderMarkers: true));
    } catch (e) {
      emit(ChartError(message: e.toString()));
    }
  }

  void _onUpdateChartData(UpdateChartData event, Emitter<ChartState> emit) {
    if (state is ChartLoaded) {
      final currentState = state as ChartLoaded;
      List<Candle> updatedCandles = List.from(currentState.candles);

      if (updatedCandles.isNotEmpty &&
          updatedCandles[0].date == event.latestCandle.date &&
          updatedCandles[0].open == event.latestCandle.open) {
        // Update last candle
        updatedCandles[0] = event.latestCandle;
      } else if (event.latestCandle.date.difference(updatedCandles[0].date) ==
          updatedCandles[0].date.difference(updatedCandles[1].date)) {
        // Add new candle
        updatedCandles.insert(0, event.latestCandle);
        if (updatedCandles.length > 100) {
          updatedCandles.removeLast();
        }
      }

      emit(ChartLoaded(
        candles: updatedCandles,
        interval: currentState.interval,
        showOrderMarkers: currentState.showOrderMarkers,
      ));
    }
  }

  Future<void> _onChangeInterval(
      ChangeInterval event, Emitter<ChartState> emit) async {
    try {
      emit(ChartLoading());
      final candles = await _fetchInitialCandles(interval: event.interval);
      _subscribeToKlineUpdates(event.interval);
      emit(ChartLoaded(
        candles: candles,
        interval: event.interval,
        showOrderMarkers: (state as ChartLoaded).showOrderMarkers,
      ));
    } catch (e) {
      emit(ChartError(message: e.toString()));
    }
  }

  void _onToggleOrderMarkers(
      ToggleOrderMarkers event, Emitter<ChartState> emit) {
    if (state is ChartLoaded) {
      final currentState = state as ChartLoaded;
      emit(ChartLoaded(
        candles: currentState.candles,
        interval: currentState.interval,
        showOrderMarkers: !currentState.showOrderMarkers,
      ));
    }
  }

  Future<List<Candle>> _fetchInitialCandles({String interval = '1m'}) async {
    final klines = await _apiService.getKlines(
      symbol: symbol,
      interval: interval,
      limit: 100,
    );
    return klines
        .map((kline) {
          try {
            return Candle(
              date: DateTime.fromMillisecondsSinceEpoch(kline[0]),
              high: double.parse(kline[2]),
              low: double.parse(kline[3]),
              open: double.parse(kline[1]),
              close: double.parse(kline[4]),
              volume: double.parse(kline[5]),
            );
          } catch (e) {
            return null;
          }
        })
        .where((candle) => candle != null)
        .cast<Candle>()
        .toList()
        .reversed
        .toList();
  }

  void _subscribeToKlineUpdates(String interval) {
    _klineSubscription?.cancel();
    _klineSubscription =
        _apiService.getKlineStream(symbol, interval).listen((event) {
      if (event['e'] == 'kline') {
        final kline = event['k'];
        final candle = Candle(
          date: DateTime.fromMillisecondsSinceEpoch(kline['t']),
          high: double.parse(kline['h']),
          low: double.parse(kline['l']),
          open: double.parse(kline['o']),
          close: double.parse(kline['c']),
          volume: double.parse(kline['v']),
        );
        add(UpdateChartData(latestCandle: candle));
      }
    });
  }

  @override
  Future<void> close() {
    _klineSubscription?.cancel();
    return super.close();
  }
}
