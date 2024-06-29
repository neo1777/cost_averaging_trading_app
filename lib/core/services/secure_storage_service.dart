// lib/core/services/secure_storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveApiKey(String apiKey) async {
    await _storage.write(key: 'apiKey', value: apiKey);
  }

  Future<String?> getApiKey() async {
    return await _storage.read(key: 'apiKey');
  }

  Future<void> saveSecretKey(String secretKey) async {
    await _storage.write(key: 'secretKey', value: secretKey);
  }

  Future<String?> getSecretKey() async {
    return await _storage.read(key: 'secretKey');
  }

  Future<void> saveValue(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> getValue(String key) async {
    return await _storage.read(key: key);
  }
}
