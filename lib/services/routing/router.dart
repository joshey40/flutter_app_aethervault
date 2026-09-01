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
import '../life_counter/lifecounter_controller.dart';
import 'sheet_page.dart';
import 'sheet_scaffold.dart';
import '../../screens/home/search/search_card_sheet.dart';

GoRouter createAppRouter({required String initialLocation, required LifecounterController lifecounterController}) {
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
                  return SearchPage(
                    initialQuery: state.uri.queryParameters['q'],
                    initialScope: state.uri.queryParameters['scope'],
                    initialSort: state.uri.queryParameters['sort'],
                    initialOrder: state.uri.queryParameters['order'],
                  );
                },
                routes: [
                  GoRoute(
                    path: 'syntax-help',
                    builder: (context, state) {
                      return const ScryfallSyntaxPage();
                    },
                  ),
                  GoRoute(
                    path: 'card/:cardId',
                    pageBuilder: (context, state) {
                      final cardId = state.pathParameters['cardId']!;
                      return buildSheetPage(
                        key: state.pageKey,
                        child: CardDetailSheetScaffold(
                          child: SearchCardSheet(cardId: cardId),
                        ),
                      );
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
                  return LifecounterEntryScreen(controller: lifecounterController);
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
                        controller: lifecounterController,
                        initialStartLife: startLife,
                        initialPlayers: players,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'game',
                    builder: (context, state) {
                      return LifecounterPlayScreen(controller: lifecounterController);
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