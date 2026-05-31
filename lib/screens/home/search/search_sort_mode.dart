import '../../../services/scryfall/scryfall_search_repository.dart';

enum SearchSortMode {
  nameAsc('Name A–Z'),
  nameDesc('Name Z–A'),
  manaValueAsc('Mana Value'),
  newestFirst('Neueste zuerst'),
  oldestFirst('Älteste zuerst'),
  setAsc('Set / Nummer');

  const SearchSortMode(this.label);
  final String label;

  ScryfallSearchSortMode get repositorySortMode {
    switch (this) {
      case SearchSortMode.nameAsc:
        return ScryfallSearchSortMode.nameAsc;
      case SearchSortMode.nameDesc:
        return ScryfallSearchSortMode.nameDesc;
      case SearchSortMode.manaValueAsc:
        return ScryfallSearchSortMode.manaValueAsc;
      case SearchSortMode.newestFirst:
        return ScryfallSearchSortMode.newestFirst;
      case SearchSortMode.oldestFirst:
        return ScryfallSearchSortMode.oldestFirst;
      case SearchSortMode.setAsc:
        return ScryfallSearchSortMode.setAsc;
    }
  }
}
