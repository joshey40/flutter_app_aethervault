import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_aethervault/services/scryfall/bulk_data_type.dart';
import 'package:flutter_app_aethervault/services/scryfall/scryfall_search_query.dart';

void main() {
  group('ScryfallSearchPlanner', () {
    final planner = ScryfallSearchPlanner();

    test('uses default_cards for locally supported search terms', () {
      final plan = planner.plan('t:creature o:flying mv<=3');

      expect(plan.searchBulkType, ScryfallBulkDataType.defaultCards);
      expect(plan.collectionBulkType, ScryfallBulkDataType.allCards);
      expect(plan.query.executionMode, ScryfallSearchExecutionMode.localOnly);
      expect(plan.query.remoteOnlyTerms, isEmpty);
    });

    test('uses remote fallback for Scryfall tagger terms', () {
      final plan = planner.plan('otag:treasure t:artifact');

      expect(
        plan.query.executionMode,
        ScryfallSearchExecutionMode.localThenRemoteFallback,
      );
      expect(plan.query.remoteOnlyTerms, contains('otag:'));
      expect(plan.query.reason, isNotNull);
    });

    test('uses remote only when every detected term is remote-only', () {
      final plan = planner.plan('art:dragon');

      expect(plan.query.executionMode, ScryfallSearchExecutionMode.remoteOnly);
      expect(plan.query.localTerms, isEmpty);
      expect(plan.query.remoteOnlyTerms, contains('art:'));
    });
  });
}
