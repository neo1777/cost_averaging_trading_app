import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:cost_averaging_trading_app/app.dart';
import 'package:cost_averaging_trading_app/core/services/api_service.dart';
import 'package:cost_averaging_trading_app/core/services/database_service.dart';
import 'package:cost_averaging_trading_app/core/services/secure_storage_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carica le variabili d'ambiente
  await dotenv.load(fileName: ".env");

  final apiService = ApiService(
    apiKey: dotenv.env['API_KEY'] ?? '',
    secretKey: dotenv.env['SECRET_KEY'] ?? '',
  );
  final databaseService = await DatabaseService.getInstance();

  final secureStorageService = SecureStorageService();

  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseService>(
          create: (_) => databaseService,
        ),
        // Altri provider...
      ],
      child: App(
        apiService: apiService,
        databaseService: databaseService,
        secureStorageService: secureStorageService,
      ),
    ),
  );

  // runApp(
  //   DevicePreview(
  //     enabled: true, // Abilita DevicePreview in modalità di debug
  //     builder: (context) => App(
  //       apiService: apiService,
  //       databaseService: databaseService,
  //       secureStorageService: secureStorageService,
  //     ),
  //   ),
  // );
}
