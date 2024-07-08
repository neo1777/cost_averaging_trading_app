import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/app.dart';
import 'package:cost_averaging_trading_app/core/providers/app_providers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  if (!kIsWeb) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    const AppProviders(
      child: App(),
    ),
  );
}