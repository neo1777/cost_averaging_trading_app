import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/core/theme/app_theme.dart';
import 'package:cost_averaging_trading_app/routes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cost Averaging Trading App',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: Routes.dashboard,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
