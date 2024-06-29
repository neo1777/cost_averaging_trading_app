import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/features/settings/blocs/settings_bloc.dart';
import 'package:cost_averaging_trading_app/features/settings/blocs/settings_state.dart';
import 'package:cost_averaging_trading_app/routes.dart';
import 'package:cost_averaging_trading_app/ui/widgets/responsive_text.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveText(
          'Cost Averaging Trading App',
          style: TextStyle(fontSize: 20),
        ),
        automaticallyImplyLeading: !isDesktop,
        actions: [
          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              if (state is SettingsLoaded && state.isDemoMode) {
                return const Chip(
                  label: Text('Demo Mode'),
                  backgroundColor: Colors.orange,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      drawer: isDesktop ? null : const AppDrawer(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) const AppDrawer(),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: ResponsiveText(
              'Menu',
              style: TextStyle(fontSize: 24),
            ),
          ),
          _buildMenuItem(context, 'Dashboard', Routes.dashboard),
          _buildMenuItem(context, 'Strategy', Routes.strategy),
          _buildMenuItem(context, 'Portfolio', Routes.portfolio),
          _buildMenuItem(context, 'Trade History', Routes.tradeHistory),
          _buildMenuItem(context, 'Settings', Routes.settings),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, String route) {
    return ListTile(
      title: ResponsiveText(
        title,
        style: const TextStyle(fontSize: 18),
      ),
      onTap: () {
        Navigator.pushReplacementNamed(context, route);
      },
    );
  }
}
