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
      {Map<String, dynamic>? queryParams}) async {
    try {
      final uri =
          Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: _getHeaders(),
      );
      return _handleResponse(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('GET request failed: $endpoint', e, stackTrace);
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      body['timestamp'] = timestamp.toString();
      body['signature'] = _generateSignature(body);

      final response = await http.post(
        uri,
        headers: _getHeaders(),
        body: body,
      );
      return _handleResponse(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('POST request failed: $endpoint', e, stackTrace);
      rethrow;
    }
  }

  Map<String, String> _getHeaders() {
    return {
      'X-MBX-APIKEY': apiKey,
      'Content-Type': 'application/x-www-form-urlencoded',
    };
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
          'HTTP error ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  Future<dynamic> getAccountInfo() async {
    try {
      return await get('/api/v3/account');
    } catch (e, stackTrace) {
      ErrorHandler.logError('Failed to get account info', e, stackTrace);
      rethrow;
    }
  }

  Future<dynamic> createOrder({
    required String symbol,
    required String side,
    required String type,
    required String quantity,
    String? price,
    String? stopPrice,
  }) async {
    try {
      final body = {
        'symbol': symbol,
        'side': side,
        'type': type,
        'quantity': quantity,
        if (price != null) 'price': price,
        if (stopPrice != null) 'stopPrice': stopPrice,
      };
      return await post('/api/v3/order', body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Failed to create order', e, stackTrace);
      rethrow;
    }
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
    final queryParams = symbol != null ? {'symbol': symbol} : null;
    return await get('/api/v3/openOrders', queryParams: queryParams);
  }

  Future<dynamic> getAllOrders({required String symbol}) async {
    return await get('/api/v3/allOrders', queryParams: {'symbol': symbol});
  }

  Future<dynamic> getExchangeInfo() async {
    return await get('/api/v3/exchangeInfo');
  }

  Future<List<Map<String, dynamic>>> getKlines({
    required String symbol,
    required String interval,
    int? limit,
    int? startTime,
    int? endTime,
  }) async {
    try {
      final queryParams = {
        'symbol': symbol,
        'interval': interval,
        if (limit != null) 'limit': limit.toString(),
        if (startTime != null) 'startTime': startTime.toString(),
        if (endTime != null) 'endTime': endTime.toString(),
      };
      final response = await get('/api/v3/klines', queryParams: queryParams);
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Failed to get klines', e, stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> get24hrTickerPriceChange(String symbol) async {
    try {
      return await get('/api/v3/ticker/24hr', queryParams: {'symbol': symbol});
    } catch (e, stackTrace) {
      ErrorHandler.logError(
          'Failed to get 24hr ticker price change', e, stackTrace);
      rethrow;
    }
  }

  Future<double> getCurrentPrice(String symbol) async {
    try {
      final response =
          await get('/api/v3/ticker/price', queryParams: {'symbol': symbol});
      return double.parse(response['price']);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Failed to get current price', e, stackTrace);
      rethrow;
    }
  }
}
