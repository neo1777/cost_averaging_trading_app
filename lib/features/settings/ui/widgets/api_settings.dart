// lib/features/settings/ui/widgets/api_settings.dart

import 'package:flutter/material.dart';

class ApiSettings extends StatelessWidget {
  final String apiKey;
  final String secretKey;
  final Function(String) onApiKeyChanged;
  final Function(String) onSecretKeyChanged;

  const ApiSettings({
    super.key,
    required this.apiKey,
    required this.secretKey,
    required this.onApiKeyChanged,
    required this.onSecretKeyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('API Settings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: apiKey,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
              ),
              onChanged: onApiKeyChanged,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: secretKey,
              decoration: const InputDecoration(
                labelText: 'Secret Key',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              onChanged: onSecretKeyChanged,
            ),
          ],
        ),
      ),
    );
  }
}