import 'dart:async';
import 'dart:math';

import 'package:candlesticks/candlesticks.dart';
import 'package:cost_averaging_trading_app/core/services/api_service.dart';
import 'package:cost_averaging_trading_app/features/chart/blocs/chart_event.dart';
import 'package:cost_averaging_trading_app/features/chart/blocs/chart_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    on<UpdateTicker>(_onUpdateTicker); // Add this line
  }

  Future<void> _onLoadChartData(
      LoadChartData event, Emitter<ChartState> emit) async {
    try {
      emit(ChartLoading());
      final candles = await _fetchInitialCandles();
      _subscribeToKlineUpdates('1m'); // Make sure this line is present
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
          updatedCandles.last.date == event.latestCandle.date) {
        updatedCandles[updatedCandles.length - 1] = event.latestCandle;
      } else {
        updatedCandles.add(event.latestCandle);
        if (updatedCandles.length > 100) {
          updatedCandles.removeAt(0);
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
    return klines.map((kline) => _klineToCandle(kline)).toList();
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

    // Sottoscrizione separata per gli aggiornamenti del ticker in tempo reale
    _apiService.getTickerStream(symbol).listen((event) {
      if (event.containsKey('c')) {
        add(UpdateTicker(event));
      }
    });

    // Aggiungi una sottoscrizione separata per gli aggiornamenti in tempo reale
    _apiService.getTickerStream(symbol).listen((event) {
      if (state is ChartLoaded) {
        final currentState = state as ChartLoaded;
        final lastCandle = currentState.candles.last;
        final updatedCandle = Candle(
          date: lastCandle.date,
          high: max(lastCandle.high, double.parse(event['p'])),
          low: min(lastCandle.low, double.parse(event['p'])),
          open: lastCandle.open,
          close: double.parse(event['p']),
          volume: lastCandle.volume + double.parse(event['p']),
        );

        add(UpdateChartData(latestCandle: updatedCandle));
      }
    });
  }

  Candle _klineToCandle(List<dynamic> kline) {
    return Candle(
      date: DateTime.fromMillisecondsSinceEpoch(kline[0]),
      high: double.parse(kline[2]),
      low: double.parse(kline[3]),
      open: double.parse(kline[1]),
      close: double.parse(kline[4]),
      volume: double.parse(kline[5]),
    );
  }

  @override
  Future<void> close() {
    _klineSubscription?.cancel();
    return super.close();
  }

  void _onUpdateTicker(UpdateTicker event, Emitter<ChartState> emit) {
    if (state is ChartLoaded) {
      final currentState = state as ChartLoaded;
      final lastCandle = currentState.candles.last;
      final closePrice = event.tickerData['c'];
      if (closePrice != null) {
        final updatedCandle = Candle(
          date: lastCandle.date,
          high: max(lastCandle.high, double.parse(closePrice)),
          low: min(lastCandle.low, double.parse(closePrice)),
          open: lastCandle.open,
          close: double.parse(closePrice),
          volume: lastCandle.volume,
        );
        final updatedCandles = List<Candle>.from(currentState.candles);
        updatedCandles[updatedCandles.length - 1] = updatedCandle;
        emit(ChartLoaded(
          candles: updatedCandles,
          interval: currentState.interval,
          showOrderMarkers: currentState.showOrderMarkers,
        ));
      }
    }
  }
}
