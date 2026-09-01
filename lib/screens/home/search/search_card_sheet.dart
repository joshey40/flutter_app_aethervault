import 'package:flutter/material.dart';
import '../../../../services/card_database/database.dart';
import '../../../../services/localization_service.dart';
import 'package:flutter_app_aethervault/screens/widgets/card_details/card_detail_body.dart';

class SearchCardSheet extends StatefulWidget {
  const SearchCardSheet({required this.cardId, super.key});

  final String cardId;

  @override
  State<SearchCardSheet> createState() => _SearchCardSheetState();
}

class _SearchCardSheetState extends State<SearchCardSheet> {
  final AppDatabase _database = AppDatabase();

  ScryfallCard? _card;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCard();
  }

  Future<void> _loadCard() async {
    try {
      final card = await _database.getCardById(widget.cardId);

      if (!mounted) return;
      setState(() {
        _card = card;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '${appLocalizations.translate('search.search_error')}: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_card == null) {
      return Center(child: Text(appLocalizations.translate('search.no_results')));
    }

    return CardDetailBody(
      card: _card!,
      actions: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: [
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: Text(appLocalizations.translate('card_detail.add_to_collection')),
            onPressed: () {
              // TODO: Collection-Add-Logik
            },
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.playlist_add),
            label: Text(appLocalizations.translate('card_detail.add_to_deck')),
            onPressed: () {
              // TODO: Deck-Picker öffnen
            },
          ),
        ],
      ),
    );
  }
}