import 'package:flutter/material.dart';

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Demo Mode', style: Theme.of(context).textTheme.titleMedium),
            Switch(
              value: isDemoMode,
              onChanged: onToggle,
            ),
          ],
        ),
      ),
    );
  }
}