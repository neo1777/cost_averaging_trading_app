// lib/features/settings/repositories/settings_repository.dart

import 'package:cost_averaging_trading_app/core/services/secure_storage_service.dart';
import 'package:cost_averaging_trading_app/features/settings/models/settings_model.dart';

class SettingsRepository {
  final SecureStorageService _secureStorage;

  SettingsRepository(this._secureStorage);

   Future<SettingsModel> getSettings() async {
    final apiKey = await _secureStorage.getApiKey() ?? '';
    final secretKey = await _secureStorage.getSecretKey() ?? '';
    final isDemoMode = await _secureStorage.getValue('isDemoMode') == 'true';
    final isBacktestingEnabled = await _secureStorage.getValue('isBacktestingEnabled') == 'true';
    final maxLossPercentage = double.parse(await _secureStorage.getValue('maxLossPercentage') ?? '2.0');
    final maxConcurrentTrades = int.parse(await _secureStorage.getValue('maxConcurrentTrades') ?? '3');
    final maxPositionSizePercentage = double.parse(await _secureStorage.getValue('maxPositionSizePercentage') ?? '5.0');
    final dailyExposureLimit = double.parse(await _secureStorage.getValue('dailyExposureLimit') ?? '1000.0');
    final maxAllowedVolatility = double.parse(await _secureStorage.getValue('maxAllowedVolatility') ?? '0.05');
    final maxRebuyCount = int.parse(await _secureStorage.getValue('maxRebuyCount') ?? '3');
    final maxVariableInvestmentPercentage = double.parse(await _secureStorage.getValue('maxVariableInvestmentPercentage') ?? '20.0');

    return SettingsModel(
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
      maxVariableInvestmentPercentage: maxVariableInvestmentPercentage,
    );
  }

  Future<void> updateSettings(SettingsModel settings) async {
    await _secureStorage.saveApiKey(settings.apiKey);
    await _secureStorage.saveSecretKey(settings.secretKey);
    await _secureStorage.saveValue('isDemoMode', settings.isDemoMode.toString());
    await _secureStorage.saveValue('isBacktestingEnabled', settings.isBacktestingEnabled.toString());
    await _secureStorage.saveValue('maxLossPercentage', settings.maxLossPercentage.toString());
    await _secureStorage.saveValue('maxConcurrentTrades', settings.maxConcurrentTrades.toString());
    await _secureStorage.saveValue('maxPositionSizePercentage', settings.maxPositionSizePercentage.toString());
    await _secureStorage.saveValue('dailyExposureLimit', settings.dailyExposureLimit.toString());
    await _secureStorage.saveValue('maxAllowedVolatility', settings.maxAllowedVolatility.toString());
    await _secureStorage.saveValue('maxRebuyCount', settings.maxRebuyCount.toString());
    await _secureStorage.saveValue('maxVariableInvestmentPercentage', settings.maxVariableInvestmentPercentage.toString());
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


