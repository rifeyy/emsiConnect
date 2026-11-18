import 'package:flutter/material.dart';

import 'courses_page.dart';
import 'login_page.dart';
import 'multimedia_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => page,
      ),
    );
  }

  void _openFromDrawer(BuildContext context, Widget page) {
    final navigator = Navigator.of(context);

    // Fermer le Drawer.
    navigator.pop();

    // Ouvrir la page choisie.
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => page,
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  void _logout(BuildContext context) {
    final navigator = Navigator.of(context);

    // Fermer le Drawer.
    navigator.pop();

    // Revenir à la connexion et supprimer les anciennes routes.
    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('EMSI Connect'),
        centerTitle: true,
      ),

      // Menu latéral.
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: colors.primary,
              ),
              accountName: const Text('Étudiant EMSI'),
              accountEmail: const Text('etudiant@emsi.ma'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: colors.onPrimary,
                child: Icon(
                  Icons.person,
                  size: 42,
                  color: colors.primary,
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Accueil'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('Mes cours'),
              onTap: () {
                _openFromDrawer(
                  context,
                  CoursesPage(),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Mon profil'),
              onTap: () {
                _openFromDrawer(
                  context,
                  ProfilePage(),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.perm_media_outlined),
              title: const Text('Espace multimédia'),
              onTap: () {
                _openFromDrawer(
                  context,
                  const MultimediaPage(),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Paramètres'),
              onTap: () {
                _openFromDrawer(
                  context,
                  const SettingsPage(),
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('À propos'),
              onTap: () {
                _openFromDrawer(
                  context,
                  const AboutPage(),
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () {
                _logout(context);
              },
            ),
          ],
        ),
      ),

      // Contenu principal.
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1100,
            ),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Carte de bienvenue.
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 48,
                        color: colors.onPrimaryContainer,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Bienvenue sur EMSI Connect',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Retrouve tes cours, ton profil '
                        'et tes outils étudiants.',
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Tableau de bord',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Grille adaptative.
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    final int columns;

                    if (width >= 900) {
                      columns = 4;
                    } else if (width >= 500) {
                      columns = 2;
                    } else {
                      columns = 1;
                    }

                    return GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 180,
                      children: [
                        _DashboardCard(
                          title: 'Mes cours',
                          subtitle: 'Consulter les modules',
                          icon: Icons.menu_book_outlined,
                          onTap: () {
                            _openPage(
                              context,
                              CoursesPage(),
                            );
                          },
                        ),

                        _DashboardCard(
                          title: 'Mon profil',
                          subtitle: 'Voir mes informations',
                          icon: Icons.person_outline,
                          onTap: () {
                            _openPage(
                              context,
                              ProfilePage(),
                            );
                          },
                        ),

                        _DashboardCard(
                          title: 'Planning',
                          subtitle: 'Mon emploi du temps',
                          icon: Icons.calendar_month_outlined,
                          onTap: () {
                            _showMessage(
                              context,
                              'Planning : fonctionnalité à venir.',
                            );
                          },
                        ),

                        _DashboardCard(
                          title: 'Mes tâches',
                          subtitle: 'Organiser mon travail',
                          icon: Icons.task_alt,
                          onTap: () {
                            _showMessage(
                              context,
                              'Mes tâches : fonctionnalité à venir.',
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Accès rapide au multimédia.
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Icon(
                      Icons.perm_media_outlined,
                      color: colors.primary,
                      size: 36,
                    ),
                    title: const Text(
                      'Espace multimédia',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'Photos, galerie et questions vocales',
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                    ),
                    onTap: () {
                      _openPage(
                        context,
                        const MultimediaPage(),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Carte réutilisable du tableau de bord.
class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 38,
                color: colors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Page À propos, incluse dans ce fichier.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.school,
                    size: 80,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'EMSI Connect',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Version pédagogique 1.0.0',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Application Flutter réalisée dans le cadre des TP. '
                    'Elle regroupe les cours, le profil étudiant, '
                    'les paramètres et les fonctionnalités multimédias.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Retour'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}