import 'package:flutter/material.dart';

import '../../services/localization_service.dart';
import 'settings/settings_page.dart';
import 'collection_page.dart';
import 'decks_page.dart';
import 'overview_page.dart';
import 'search/search_page.dart';
import 'lifecounter/screens/lifecounter_entry_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.locale,
    required this.onLocaleChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final Locale locale;
  final Future<void> Function(Locale locale) onLocaleChanged;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      OverviewPage(key: ValueKey('overview-${widget.locale.languageCode}')),
      SearchPage(key: ValueKey('search-${widget.locale.languageCode}')),
      CollectionPage(key: ValueKey('collection-${widget.locale.languageCode}')),
      DecksPage(key: ValueKey('decks-${widget.locale.languageCode}')),
      LifecounterEntryScreen(key: ValueKey('lifecounter-${widget.locale.languageCode}')),
      SettingsPage(
        key: ValueKey('settings-${widget.locale.languageCode}'),
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
        locale: widget.locale,
        onLocaleChanged: widget.onLocaleChanged,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: appLocalizations.translate('nav.overview'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search_outlined),
            activeIcon: const Icon(Icons.search),
            label: appLocalizations.translate('nav.search'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.style_outlined),
            activeIcon: const Icon(Icons.style),
            label: appLocalizations.translate('nav.collection'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.space_dashboard_outlined),
            activeIcon: const Icon(Icons.space_dashboard),
            label: appLocalizations.translate('nav.decks'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_border),
            activeIcon: const Icon(Icons.favorite),
            label: appLocalizations.translate('nav.play'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: appLocalizations.translate('nav.settings'),
          ),
        ],
      ),
    );
  }
}
