import 'package:flutter/material.dart';

import '../../../services/localization_service.dart';
import '../../../services/scryfall/download_service.dart';
import '../../../services/services_provider.dart';

// Search functionality removed per request; placeholder UI only.


// ---------------------------------------------------------------------------
// Search Page
// ---------------------------------------------------------------------------

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _allCardsAvailable = false;
  bool _checkingAvailability = true;
  int? _loadedCardCount;
  // search UI state (search engine removed)
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String? _searchError;
  List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    _checkScryfallAvailability();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkScryfallAvailability() async {
    setState(() => _checkingAvailability = true);
    try {
      final available = await DownloadService.instance.isAllCardsAvailable();
      if (!mounted) return;
      // CardsDataService removed; only show availability of the raw file
      setState(() => _loadedCardCount = null);
      setState(() => _allCardsAvailable = available);
    } catch (_) {
      setState(() => _allCardsAvailable = false);
    } finally {
      setState(() => _checkingAvailability = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // Aktives Suchfeld
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: loc.translate('search.placeholder'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 96,
                  child: ElevatedButton(
                    onPressed: null,
                    child: const Text('Suche deaktiviert'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Availability row
            Card(
              child: ListTile(
                leading: _checkingAvailability
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _allCardsAvailable ? Icons.check_circle : Icons.error_outline,
                        color: _allCardsAvailable ? Colors.green : Colors.red,
                      ),
                title: Text(_checkingAvailability
                    ? 'Prüfe Scryfall-Daten...'
                    : (_allCardsAvailable ? 'Scryfall-Datei vorhanden' : 'Scryfall-Datei fehlt')),
                subtitle: _loadedCardCount != null ? Text('Geladene Karten: $_loadedCardCount') : null,
                trailing: TextButton.icon(
                  onPressed: _checkScryfallAvailability,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Aktualisieren'),
                ),
              ),
            ),

            const SizedBox(height: 12),

            const SizedBox(height: 12),

            // Results or placeholders
            Expanded(
              child: _buildResultsArea(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsArea() {
    return Center(child: Text('Suche wurde entfernt.'));
  }

  Future<void> _performSearch() async {
    // Search functionality removed.
    return;
  }

}
