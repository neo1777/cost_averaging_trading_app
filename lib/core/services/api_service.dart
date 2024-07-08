import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ApiService {
  final String apiKey;
  final String secretKey;
  final String baseUrl = 'https://api.binance.com';

  ApiService({required this.apiKey, required this.secretKey});

  Future<int> getServerTime() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/v3/time'));
      if (response.statusCode == 200) {
        final serverTime = json.decode(response.body)['serverTime'];
        return serverTime;
      } else {
        throw Exception('Failed to get server time');
      }
    } catch (e) {
      rethrow;
    }
  }

  Stream<Map<String, dynamic>> getTickerStream(String symbol) {
    final wsUrl =
        'wss://stream.binance.com:9443/ws/${symbol.toLowerCase()}@ticker';
    final channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    return channel.stream.map((event) => jsonDecode(event));
  }

  Future<double> getAccountBalance(String asset) async {
    try {
      final accountInfo = await getAccountInfo();
      final balances = accountInfo['balances'] as List<dynamic>;
      final assetBalance = balances.firstWhere(
        (balance) => balance['asset'] == asset,
        orElse: () => {'free': '0'},
      );
      return double.parse(assetBalance['free']);
    } catch (e) {
      throw Exception('Failed to get account balance: $e');
    }
  }

  Future<Map<String, dynamic>> createMarketSellOrder(
      String symbol, double quantity) async {
    try {
      final response = await createOrder(
        symbol: symbol,
        side: 'SELL',
        type: 'MARKET',
        quantity: quantity.toStringAsFixed(8),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to create market sell order: $e');
    }
  }

  Future<dynamic> get(String endpoint,
      {Map<String, dynamic>? queryParams, bool requiresAuth = false}) async {
    try {
      var params = queryParams ?? {};
      if (requiresAuth) {
        final serverTime = await getServerTime();
        params['timestamp'] = serverTime.toString();
        params['recvWindow'] = '60000';
        params['signature'] = _generateSignature(params);
      }

      final uri =
          Uri.parse('$baseUrl$endpoint').replace(queryParameters: params);

      final response = await http.get(
        uri,
        headers: _getHeaders(requiresAuth),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('GET request failed: $endpoint. Error: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body,
      {bool requiresAuth = true}) async {
    try {
      if (requiresAuth) {
        final serverTime = await getServerTime();
        body['timestamp'] = serverTime.toString();
        body['recvWindow'] = '60000';
        body['signature'] = _generateSignature(body);
      }

      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await http.post(
        uri,
        headers: _getHeaders(requiresAuth),
        body: body,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('POST request failed: $endpoint. Error: $e');
    }
  }

  Map<String, String> _getHeaders(bool requiresAuth) {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    if (requiresAuth) {
      headers['X-MBX-APIKEY'] = apiKey;
    }
    return headers;
  }

  String _generateSignature(Map<String, dynamic> params) {
    final queryString = Uri(queryParameters: params).query;
    final hmac = Hmac(sha256, utf8.encode(secretKey));
    final signature = hmac.convert(utf8.encode(queryString)).toString();
    return signature;
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'HTTP error ${response.statusCode}: ${response.reasonPhrase}\nBody: ${response.body}');
    }
  }

  Future<dynamic> getAccountInfo() async {
    return await get('/api/v3/account', requiresAuth: true);
  }

  Future<dynamic> createOrder({
    required String symbol,
    required String side,
    required String type,
    required String quantity,
    String? price,
    String? stopPrice,
  }) async {
    final body = {
      'symbol': symbol,
      'side': side,
      'type': type,
      'quantity': quantity,
      if (price != null) 'price': price,
      if (stopPrice != null) 'stopPrice': stopPrice,
    };
    return await post('/api/v3/order', body);
  }

  Future<dynamic> cancelOrder({
    required String symbol,
    String? orderId,
    String? origClientOrderId,
  }) async {
    final body = {
      'symbol': symbol,
      if (orderId != null) 'orderId': orderId,
      if (origClientOrderId != null) 'origClientOrderId': origClientOrderId,
    };
    return await post('/api/v3/order', body);
  }

  Future<dynamic> getOpenOrders({String? symbol}) async {
    return await get('/api/v3/openOrders',
        queryParams: symbol != null ? {'symbol': symbol} : null,
        requiresAuth: true);
  }

  Future<dynamic> getAllOrders({required String symbol}) async {
    return await get('/api/v3/allOrders',
        queryParams: {'symbol': symbol}, requiresAuth: true);
  }

  Future<dynamic> getExchangeInfo() async {
    return await get('/api/v3/exchangeInfo', requiresAuth: false);
  }

  Future<List<List<dynamic>>> getKlines({
    required String symbol,
    required String interval,
    int? limit,
    int? startTime,
    int? endTime,
  }) async {
    final queryParams = {
      'symbol': symbol,
      'interval': interval,
      if (limit != null) 'limit': limit.toString(),
      if (startTime != null) 'startTime': startTime.toString(),
      if (endTime != null) 'endTime': endTime.toString(),
    };

    final uri = Uri.parse('$baseUrl/api/v3/klines')
        .replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return List<List<dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load klines');
    }
  }

  Future<Map<String, dynamic>> get24hrTickerPriceChange(String symbol) async {
    return await get('/api/v3/ticker/24hr',
        queryParams: {'symbol': symbol}, requiresAuth: false);
  }

  Stream<Map<String, dynamic>> getKlineStream(String symbol, String interval) {
    final wsUrl =
        'wss://stream.binance.com:9443/ws/${symbol.toLowerCase()}@kline_$interval';
    final channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    return channel.stream.map((event) {
      return jsonDecode(event);
    });
  }

  Future<double> getCurrentPrice(String symbol) async {
    try {
      final response = await get('/api/v3/ticker/price',
          queryParams: {'symbol': symbol}, requiresAuth: false);
      if (response is Map<String, dynamic> && response.containsKey('price')) {
        return double.parse(response['price']);
      } else {
        throw Exception('Unexpected response format for price');
      }
    } catch (e) {
      return 0.0; // Return a default value or throw an exception based on your needs
    }
  }

  Future<List<String>> getValidTradingSymbols() async {
    final response = await get('/api/v3/exchangeInfo', requiresAuth: false);
    final symbols = (response['symbols'] as List<dynamic>)
        .map((symbol) => symbol['symbol'] as String)
        .toList();
    return symbols;
  }

  Future<List<Map<String, dynamic>>> getMyTrades(
      {required String symbol, int? limit, int? startTime}) async {
    try {
      final params = {
        'symbol': symbol,
        if (limit != null) 'limit': limit.toString(),
        if (startTime != null) 'startTime': startTime.toString(),
      };
      final response = await get('/api/v3/myTrades',
          queryParams: params, requiresAuth: true);
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getAccountTradeList({required String symbol}) async {
    return await get('/api/v3/myTrades',
        queryParams: {'symbol': symbol}, requiresAuth: true);
  }

  Future<dynamic> getDepositHistory() async {
    return await get('/sapi/v1/capital/deposit/hisrec', requiresAuth: true);
  }

  Future<dynamic> getWithdrawHistory() async {
    return await get('/sapi/v1/capital/withdraw/history', requiresAuth: true);
  }

  Future<dynamic> getDepositAddress({required String coin}) async {
    return await get('/sapi/v1/capital/deposit/address',
        queryParams: {'coin': coin}, requiresAuth: true);
  }

  Future<dynamic> withdraw({
    required String coin,
    required String address,
    required String amount,
    String? network,
  }) async {
    final body = {
      'coin': coin,
      'address': address,
      'amount': amount,
      if (network != null) 'network': network,
    };
    return await post('/sapi/v1/capital/withdraw/apply', body);
  }

  Future<double> getMinimumTradeAmount(String symbol) async {
    try {
      final response = await get('/api/v3/exchangeInfo',
          queryParams: {'symbol': symbol}, requiresAuth: false);
      final filters = response['symbols'][0]['filters'] as List<dynamic>;
      final lotSizeFilter =
          filters.firstWhere((filter) => filter['filterType'] == 'LOT_SIZE');
      return double.parse(lotSizeFilter['minQty']);
    } catch (e) {
      // In caso di errore, restituisci un valore di default
      return 0.00001; // Questo è un valore arbitrario, regolalo secondo le tue esigenze
    }
  }

  Stream<double> getPriceStream(String symbol) async* {
    final ws = await WebSocket.connect(
        'wss://stream.binance.com:9443/ws/$symbol@trade');

    try {
      await for (var message in ws) {
        final data = json.decode(message);
        yield double.parse(data['p']);
      }
    } finally {
      await ws.close();
    }
  }

  Future<String> createMarketBuyOrder(String symbol, double quantity) async {
    return await createOrder(
      symbol: symbol,
      side: 'BUY',
      type: 'MARKET',
      quantity: quantity.toStringAsFixed(8),
    );
  }

  Future<String> createLimitBuyOrder(
      String symbol, double quantity, double price) async {
    return await createOrder(
      symbol: symbol,
      side: 'BUY',
      type: 'LIMIT',
      quantity: quantity.toStringAsFixed(8),
      price: price.toStringAsFixed(8),
    );
  }

  Future<String> createLimitSellOrder(
      String symbol, double quantity, double price) async {
    return await createOrder(
      symbol: symbol,
      side: 'SELL',
      type: 'LIMIT',
      quantity: quantity.toStringAsFixed(8),
      price: price.toStringAsFixed(8),
    );
  }
}
