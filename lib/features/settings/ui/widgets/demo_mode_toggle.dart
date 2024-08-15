import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/core/widgets/custom_card.dart';

class DemoModeToggle extends StatelessWidget {
  final bool isDemoMode;
  final ValueChanged<bool> onToggle;

  const DemoModeToggle({
    super.key,
    required this.isDemoMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      title: 'Trading Mode',
      child: SwitchListTile(
        title: const Text('Demo Mode'),
        subtitle: const Text('Practice trading without real funds'),
        value: isDemoMode,
        onChanged: onToggle,
      ),
    );
  }
}