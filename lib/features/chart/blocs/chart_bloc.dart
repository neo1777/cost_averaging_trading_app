// ignore_for_file: avoid_print

import 'dart:async';
import 'package:cost_averaging_trading_app/candlestick/models/candle.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import 'package:cost_averaging_trading_app/core/services/api_service.dart';
import 'package:cost_averaging_trading_app/features/chart/blocs/chart_event.dart';
import 'package:cost_averaging_trading_app/features/chart/blocs/chart_state.dart';

class ChartBloc extends Bloc<ChartEvent, ChartState> {
  final ApiService _apiService;
  final String symbol;
  StreamSubscription<dynamic>? _klineSubscription;

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
  final Logger _logger = Logger('ChartBloc');

  ChartBloc({required this.symbol, required ApiService apiService})
      : _apiService = apiService,
        super(ChartLoading()) {
    on<LoadChartData>(_onLoadChartData);
    on<UpdateChartData>(_onUpdateChartData);
    on<ChangeInterval>(_onChangeInterval);
    on<ChangeSymbol>(_onChangeSymbol);
    on<ToggleOrderMarkers>(_onToggleOrderMarkers);
    on<LoadMoreCandles>(_onLoadMoreCandles);
    add(LoadChartData());
  }

  Future<void> _onLoadChartData(
    LoadChartData event,
    Emitter<ChartState> emit,
  ) async {
    try {
      emit(ChartLoading());
      final candles = await _fetchInitialCandles();
      print('Fetched ${candles.length} candles'); // Aggiungi questo log
      if (candles.isNotEmpty) {
        _subscribeToKlineUpdates('1m');
        emit(ChartLoaded(
          candles: candles,
          interval: '1m',
          showOrderMarkers: true,
          symbol: symbol,
        ));
        print('Emitted ChartLoaded state'); // Aggiungi questo log
      } else {
        emit(const ChartError(message: 'No candles data available'));
      }
    } catch (e) {
      print('Error in _onLoadChartData: $e'); // Aggiungi questo log
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
      } else {
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
        symbol: currentState.symbol,
      ));
    }
  }

  Future<void> _onChangeInterval(
      ChangeInterval event, Emitter<ChartState> emit) async {
    try {
      emit(ChartLoading());
      final candles =
          await _fetchInitialCandles(interval: event.interval, symbol: symbol);
      if (candles.isEmpty) {
        emit(const ChartError(message: 'No data available for this interval'));
        return;
      }
      _subscribeToKlineUpdates(event.interval);
      emit(ChartLoaded(
        candles: candles,
        interval: event.interval,
        showOrderMarkers: true, // o false, a seconda delle tue esigenze
        symbol: symbol,
      ));
    } catch (e) {
      _logger.severe('Error changing interval: $e');
      emit(ChartError(message: 'Failed to change interval: ${e.toString()}'));
    }
  }

  Future<void> _onChangeSymbol(
      ChangeSymbol event, Emitter<ChartState> emit) async {
    try {
      emit(ChartLoading());
      final candles =
          await _fetchInitialCandles(symbol: event.symbol, interval: '1m');
      if (candles.isEmpty) {
        emit(const ChartError(message: 'No data available for this symbol'));
        return;
      }
      _subscribeToKlineUpdates('1m', symbol: event.symbol);
      emit(ChartLoaded(
        candles: candles,
        interval: '1m',
        showOrderMarkers: true, // o false, a seconda delle tue esigenze
        symbol: event.symbol,
      ));
    } catch (e) {
      _logger.severe('Error changing symbol: $e');
      emit(ChartError(message: 'Failed to change symbol: ${e.toString()}'));
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
        symbol: currentState.symbol,
      ));
    }
  }

  Future<List<Candle>> _fetchInitialCandles(
      {String? interval, String? symbol}) async {
    try {
      final klines = await _apiService.getKlines(
        symbol: symbol ?? this.symbol,
        interval: interval ?? '1m',
        limit: 100, // Aumentiamo il limite per avere più dati
      );
      return klines.map((kline) => Candle.fromJson(kline)).toList();
    } catch (e) {
      _logger.severe('Error fetching initial candles: $e');
      return []; // Ritorniamo una lista vuota in caso di errore
    }
  }

  void _subscribeToKlineUpdates(String interval, {String? symbol}) {
    _klineSubscription?.cancel();
    _klineSubscription = _apiService
        .getKlineStream(symbol ?? this.symbol, interval)
        .listen((event) {
      _logger.info('Received kline event: $event');
      try {
        Candle candle;
        if (event is Map<String, dynamic>) {
          if (event['e'] == 'kline') {
            candle = Candle.fromJson(event['k']);
          } else {
            _logger.warning('Unexpected event type: ${event['e']}');
            return;
          }
        } else if (event is List<dynamic>) {
          candle = Candle.fromJson(event);
        } else {
          _logger.warning('Unexpected event type: ${event.runtimeType}');
          return;
        }
        add(UpdateChartData(latestCandle: candle));
      } catch (e, stackTrace) {
        _logger.severe('Error processing kline data', e, stackTrace);
      }
    });
  }

  Future<void> _onLoadMoreCandles(
    LoadMoreCandles event,
    Emitter<ChartState> emit,
  ) async {
    if (state is ChartLoaded) {
      final currentState = state as ChartLoaded;
      try {
        final newCandles = await _apiService.getKlines(
          symbol: event.symbol,
          interval: event.interval,
          // Usa 'endTime' come parametro opzionale se disponibile nell'ApiService
          // Altrimenti, potresti dover usare 'limit' e calcolare il timestamp di inizio
          limit: 100,
        );

        final updatedCandles = [
          ...currentState.candles,
          ...newCandles.map((kline) => Candle.fromJson(kline)),
        ];

        emit(ChartLoaded(
          candles: updatedCandles,
          interval: currentState.interval,
          showOrderMarkers: currentState.showOrderMarkers,
          symbol: currentState.symbol,
        ));
      } catch (e) {
        emit(ChartError(
            message: 'Failed to load more candles: ${e.toString()}'));
      }
    }
  }

  @override
  Future<void> close() {
    _klineSubscription?.cancel();
    return super.close();
  }
}
