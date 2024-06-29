// lib/features/settings/repositories/settings_repository.dart

import 'package:cost_averaging_trading_app/core/services/secure_storage_service.dart';

class SettingsRepository {
  final SecureStorageService _secureStorage;

  SettingsRepository(this._secureStorage);

  Future<Settings> getSettings() async {
    final apiKey = await _secureStorage.getApiKey() ?? '';
    final secretKey = await _secureStorage.getSecretKey() ?? '';
    final isDemoMode = await _secureStorage.getValue('isDemoMode') == 'true';
    final isBacktestingEnabled =
        await _secureStorage.getValue('isBacktestingEnabled') == 'true';
    final maxLossPercentage = double.parse(
        await _secureStorage.getValue('maxLossPercentage') ?? '2.0');
    final maxConcurrentTrades =
        int.parse(await _secureStorage.getValue('maxConcurrentTrades') ?? '3');
    final maxPositionSizePercentage = double.parse(
        await _secureStorage.getValue('maxPositionSizePercentage') ?? '10.0');
    final dailyExposureLimit = double.parse(
        await _secureStorage.getValue('dailyExposureLimit') ?? '1000.0');
    final maxAllowedVolatility = double.parse(
        await _secureStorage.getValue('maxAllowedVolatility') ?? '0.05');
    final maxRebuyCount =
        int.parse(await _secureStorage.getValue('maxRebuyCount') ?? '5');

    return Settings(
      apiKey: apiKey,
      secretKey: secretKey,
      isDemoMode: isDemoMode,
      isBacktestingEnabled: isBacktestingEnabled,
      maxLossPercentage: maxLossPercentage,
      maxConcurrentTrades: maxConcurrentTrades,
      maxPositionSizePercentage: maxPositionSizePercentage,
      dailyExposureLimit: dailyExposureLimit,
      maxAllowedVolatility: maxAllowedVolatility,
      maxRebuyCount: maxRebuyCount,
    );
  }

  Future<void> updateApiKey(String apiKey) async {
    await _secureStorage.saveApiKey(apiKey);
  }

  Future<void> updateSecretKey(String secretKey) async {
    await _secureStorage.saveSecretKey(secretKey);
  }

  Future<void> updateDemoMode(bool isDemoMode) async {
    await _secureStorage.saveValue('isDemoMode', isDemoMode.toString());
  }

  Future<void> updateBacktestingMode(bool isBacktestingEnabled) async {
    await _secureStorage.saveValue(
        'isBacktestingEnabled', isBacktestingEnabled.toString());
  }

  Future<void> updateRiskManagement({
    required double maxLossPercentage,
    required int maxConcurrentTrades,
    required double maxPositionSizePercentage,
    required double dailyExposureLimit,
    required double maxAllowedVolatility,
    required int maxRebuyCount,
  }) async {
    await _secureStorage.saveValue(
        'maxLossPercentage', maxLossPercentage.toString());
    await _secureStorage.saveValue(
        'maxConcurrentTrades', maxConcurrentTrades.toString());
    await _secureStorage.saveValue(
        'maxPositionSizePercentage', maxPositionSizePercentage.toString());
    await _secureStorage.saveValue(
        'dailyExposureLimit', dailyExposureLimit.toString());
    await _secureStorage.saveValue(
        'maxAllowedVolatility', maxAllowedVolatility.toString());
    await _secureStorage.saveValue('maxRebuyCount', maxRebuyCount.toString());
  }
}

class Settings {
  final String apiKey;
  final String secretKey;
  final bool isDemoMode;
  final bool isBacktestingEnabled;
  final double maxLossPercentage;
  final int maxConcurrentTrades;
  final double maxPositionSizePercentage;
  final double dailyExposureLimit;
  final double maxAllowedVolatility;
  final int maxRebuyCount;

  Settings({
    required this.apiKey,
    required this.secretKey,
    required this.isDemoMode,
    required this.isBacktestingEnabled,
    required this.maxLossPercentage,
    required this.maxConcurrentTrades,
    required this.maxPositionSizePercentage,
    required this.dailyExposureLimit,
    required this.maxAllowedVolatility,
    required this.maxRebuyCount,
  });
}
