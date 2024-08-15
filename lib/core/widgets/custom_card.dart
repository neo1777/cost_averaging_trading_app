import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const CustomCard({
    super.key,
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Aggiungi questa riga
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Flexible(child: child), // Avvolgi il child in un Flexible
          ],
        ),
      ),
    );
  }
}
