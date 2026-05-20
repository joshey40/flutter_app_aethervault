import 'package:flutter/material.dart';

import '../../../services/localization_service.dart';



// ---------------------------------------------------------------------------
// Search Page
// ---------------------------------------------------------------------------

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  @override
  void initState() {
    super.initState();
    
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = appLocalizations;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('nav.search')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dekorativer, nicht-funktionaler Such-Platzhalter
            TextField(
              enabled: false,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: loc.translate('search.placeholder'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Einfache Platzhalter-Karten als Deko
            Expanded(
              child: ListView(
                children: [
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.history),
                      title: Text('Beliebte Suche', style: theme.textTheme.titleMedium),
                      subtitle: const Text('Platzhalter-Eintrag'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.star_border),
                      title: Text('Top Ergebnisse', style: theme.textTheme.titleMedium),
                      subtitle: const Text('Noch keine Funktionalität'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text('In Arbeit', style: theme.textTheme.titleMedium),
                      subtitle: const Text('Nur dekorativ'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
