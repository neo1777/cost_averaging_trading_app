// lib/features/settings/ui/widgets/api_settings.dart

import 'package:flutter/material.dart';

class ApiSettings extends StatelessWidget {
  final String apiKey;
  final String secretKey;
  final Function(String) onApiKeyChanged;
  final Function(String) onSecretKeyChanged;

  const ApiSettings({
    Key? key,
    required this.apiKey,
    required this.secretKey,
    required this.onApiKeyChanged,
    required this.onSecretKeyChanged,
  }) : super(key: key);

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
            TextField(
              decoration: const InputDecoration(
                labelText: 'API Key',
                prefixIcon: Icon(Icons.vpn_key),
              ),
              obscureText: true,
              onChanged: onApiKeyChanged,
              controller: TextEditingController(text: apiKey),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Secret Key',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              onChanged: onSecretKeyChanged,
              controller: TextEditingController(text: secretKey),
            ),
          ],
        ),
      ),
    );
  }
}
