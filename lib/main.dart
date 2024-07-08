// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/app.dart';
import 'package:cost_averaging_trading_app/core/services/api_service.dart';
import 'package:cost_averaging_trading_app/core/services/database_service.dart';
import 'package:cost_averaging_trading_app/core/services/secure_storage_service.dart';
import 'package:cost_averaging_trading_app/features/chart/blocs/chart_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  if (!kIsWeb) {
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
        Provider<ApiService>(
          create: (_) => apiService,
        ),
        BlocProvider<ChartBloc>(
          create: (context) => ChartBloc(
            symbol: 'BTCUSDT',
            apiService: apiService,
          ),
        ),
      ],
      child: App(
        apiService: apiService,
        databaseService: databaseService,
        secureStorageService: secureStorageService,
      ),
    ),
  );
}
