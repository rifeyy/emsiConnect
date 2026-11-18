import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool compactMode = false;
  bool showExtraInfo = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Préférences',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Autoriser les notifications'),
              secondary: const Icon(Icons.notifications_outlined),
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Mode compact'),
              subtitle: const Text('Réduire certains espacements'),
              secondary: const Icon(Icons.view_compact_outlined),
              value: compactMode,
              onChanged: (value) {
                setState(() {
                  compactMode = value;
                });
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Afficher les informations complémentaires'),
              subtitle: const Text('Afficher une description supplémentaire'),
              secondary: const Icon(Icons.info_outline),
              value: showExtraInfo,
              onChanged: (value) {
                setState(() {
                  showExtraInfo = value;
                });
              },
            ),
            if (showExtraInfo)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Ces paramètres sont enregistrés localement pendant la session.',
                  style: TextStyle(color: colors.primary),
                ),
              ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: EdgeInsets.all(compactMode ? 8 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'État des paramètres',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Notifications : ${notificationsEnabled ? 'Activées' : 'Désactivées'}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mode compact : ${compactMode ? 'Activé' : 'Désactivé'}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Paramètres modifiés localement'),
                  ),
                );
              },
              child: const Text('Afficher une confirmation'),
            ),
          ],
        ),
      ),
    );
  }
}