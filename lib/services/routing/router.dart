import 'package:go_router/go_router.dart';

import '../../screens/download_parser/download_screen.dart';
import '../../screens/download_parser/parser_screen.dart';
import '../../screens/home/home_shell.dart';
import '../../screens/home/overview_page.dart';
import '../../screens/home/search/search_page.dart';
import '../../screens/home/search/scryfall_syntax_page.dart';
import '../../screens/home/collection_page.dart';
import '../../screens/home/decks_page.dart';
import '../../screens/home/lifecounter/lifecounter_entry_screen.dart';
import '../../screens/home/lifecounter/lifecounter_start_screen.dart';
import '../../screens/home/lifecounter/lifecounter_play_screen.dart';
import '../../screens/home/settings/settings_page.dart';

GoRouter createAppRouter({required String initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation,
    debugLogDiagnostics: true,

    routes: [
    // ------------------------------------------------------------
    // Download / Parser
    // ------------------------------------------------------------

      GoRoute(
        path: '/download',
        builder: (context, state) {
          final forced = state.uri.queryParameters['forced'] == 'true';
          return DownloadScreen(
            forcedDownload: forced,
          );
        },
      ),

      GoRoute(
        path: '/parser',
        builder: (context, state) {
          return const ParserScreen();
        },
      ),

      // ------------------------------------------------------------
      // Home Shell
      // ------------------------------------------------------------

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShell(
            navigationShell: navigationShell,
          );
        },

        branches: [
          // Overview
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/overview',
                builder: (context, state) {
                  return const OverviewPage();
                },
              ),
            ],
          ),

          // Search
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) {

                  final query = state.uri.queryParameters['q'];

                  return SearchPage(
                    initialQuery: query,
                  );
                },
                routes: [
                  GoRoute(
                    path: 'syntax-help',
                    builder: (context, state) {
                      return const ScryfallSyntaxPage();
                    },
                  ),
                ],
              ),
            ],
          ),

          // Collection
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/collection',
                builder: (context, state) {
                  return const CollectionPage();
                },
              ),
            ],
          ),

          // Decks
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/decks',
                builder: (context, state) {
                  return const DecksPage();
                },
              ),
            ],
          ),

          // Lifecounter
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/lifecounter',
                builder: (context, state) {
                  return const LifecounterEntryScreen();
                },
                routes: [
                  GoRoute(
                    path: 'newgame',
                    builder: (context, state) {
                      final startLife = int.tryParse(
                        state.uri.queryParameters['life'] ?? '',
                      );
                      final players = int.tryParse(
                        state.uri.queryParameters['players'] ?? '',
                      );

                      return LifecounterStartScreen(
                        initialStartLife: startLife,
                        initialPlayers: players,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'game',
                    builder: (context, state) {
                      return const LifecounterPlayScreen();
                    },
                  ),
                ],
              ),
            ],
          ),

          // Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) {
                  return const SettingsPage();
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}