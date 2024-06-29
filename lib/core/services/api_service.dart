import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:cost_averaging_trading_app/core/error/error_handler.dart';

class ApiService {
  final String apiKey;
  final String secretKey;
  final String baseUrl = 'https://api.binance.com';

  ApiService({required this.apiKey, required this.secretKey});

  Future<dynamic> get(String endpoint,
      {Map<String, dynamic>? queryParams, bool requiresAuth = false}) async {
    try {
      var params = queryParams ?? {};
      if (requiresAuth) {
        params['timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();
        params['signature'] = _generateSignature(params);
      }

      final uri =
          Uri.parse('$baseUrl$endpoint').replace(queryParameters: params);
      final response = await http.get(
        uri,
        headers: _getHeaders(requiresAuth),
      );
      return _handleResponse(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('GET request failed: $endpoint', e, stackTrace);
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body,
      {bool requiresAuth = true}) async {
    try {
      if (requiresAuth) {
        body['timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();
        body['signature'] = _generateSignature(body);
      }

      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(
        uri,
        headers: _getHeaders(requiresAuth),
        body: body,
      );
      return _handleResponse(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('POST request failed: $endpoint', e, stackTrace);
      rethrow;
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
    return hmac.convert(utf8.encode(queryString)).toString();
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

  Future<List<Map<String, dynamic>>> getKlines({
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
    final response = await get('/api/v3/klines',
        queryParams: queryParams, requiresAuth: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> get24hrTickerPriceChange(String symbol) async {
    return await get('/api/v3/ticker/24hr',
        queryParams: {'symbol': symbol}, requiresAuth: false);
  }

  Future<double> getCurrentPrice(String symbol) async {
    if (symbol.isEmpty) {
      throw ArgumentError('Symbol cannot be empty');
    }
    final response = await get('/api/v3/ticker/price',
        queryParams: {'symbol': symbol}, requiresAuth: false);
    if (response is Map<String, dynamic> && response.containsKey('price')) {
      return double.parse(response['price']);
    } else {
      throw Exception('Unexpected response format for price');
    }
  }

  Future<List<String>> getValidTradingSymbols() async {
    final response = await get('/api/v3/exchangeInfo', requiresAuth: false);
    final symbols = (response['symbols'] as List<dynamic>)
        .map((symbol) => symbol['symbol'] as String)
        .toList();
    return symbols;
  }

  Future<dynamic> getMyTrades({required String symbol}) async {
    return await get('/api/v3/myTrades',
        queryParams: {'symbol': symbol}, requiresAuth: true);
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
}
