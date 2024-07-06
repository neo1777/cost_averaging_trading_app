import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cost_averaging_trading_app/app.dart';
import 'package:cost_averaging_trading_app/core/services/api_service.dart';
import 'package:cost_averaging_trading_app/core/services/database_service.dart';
import 'package:cost_averaging_trading_app/core/services/secure_storage_service.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final apiService = ApiService(
    apiKey: dotenv.env['API_KEY'] ?? '',
    secretKey: dotenv.env['SECRET_KEY'] ?? '',
  );
  // Inizializza databaseFactory
  if (!kIsWeb) {
    // Usa sqflite_common_ffi per piattaforme diverse da web
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  final databaseService = DatabaseService();
  await databaseService.initDatabase();

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
}
