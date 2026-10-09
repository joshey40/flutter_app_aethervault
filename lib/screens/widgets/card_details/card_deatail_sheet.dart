import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../services/card_database/database.dart';
import '../../../../services/localization_service.dart';
import '../../../../services/scryfall_symbol_service.dart';

// =============================================================================
// Card detail sheet
// =============================================================================

/// Displays card information and context-specific actions for one card.
///
/// Search provides [variants] and [variantFaces] so users can switch between
/// printed versions, languages, and faces. Other contexts can keep these lists
/// empty and provide their own actions later.
class CardDetailSheet extends StatefulWidget {
  const CardDetailSheet({
    required this.card,
    this.faces = const [],
    this.variants = const [],
    this.variantFaces = const {},
    this.showSearchActions = false,
    this.showLegalities = true,
    this.showMetadata = true,
    super.key,
  });

  final ScryfallCard card;
  final List<ScryfallCardFace> faces;
  final List<ScryfallCard> variants;
  final Map<String, List<ScryfallCardFace>> variantFaces;
  final bool showSearchActions;
  final bool showLegalities;
  final bool showMetadata;

  @override
  State<CardDetailSheet> createState() => _CardDetailSheetState();
}

class _CardDetailSheetState extends State<CardDetailSheet> {
  int _faceIndex = 0;
  int _variantIndex = 0;
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.card.lang;
  }

  List<ScryfallCard> get _languageVariants {
    final variants =
        widget.variants
            .where((variant) => variant.lang == _selectedLanguage)
            .toList()
          ..sort((a, b) => b.releasedAt.compareTo(a.releasedAt));
    return variants;
  }

  List<String> get _availableLanguages =>
      widget.variants
          .map((variant) => variant.lang)
          .where((language) => language.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

  ScryfallCard get _card {
    final variants = _languageVariants;
    if (variants.isEmpty) return widget.card;
    return variants[_variantIndex.clamp(0, variants.length - 1)];
  }

  List<ScryfallCardFace> get _faces =>
      widget.variantFaces[_card.scryfallId] ?? widget.faces;

  ScryfallCardFace? get _face {
    if (_faces.isEmpty) return null;
    return _faces[_faceIndex.clamp(0, _faces.length - 1)];
  }

  String? get _imageUrl => _face?.imageNormal ?? _card.imageNormal;

  bool get _hasVariantPicker =>
      widget.showSearchActions && _languageVariants.length > 1;

  bool get _hasLanguagePicker =>
      widget.showSearchActions && _availableLanguages.length > 1;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, isWide),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),
              if (widget.showSearchActions) _buildSearchActions(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isWide) {
    final details = CardDetailInfo(
      card: _card,
      face: _face,
      showLegalities: widget.showLegalities,
      showMetadata: widget.showMetadata,
    );
    final imageSection = _buildImageSection(context);

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 300, child: imageSection),
          const SizedBox(width: 14),
          Expanded(child: details),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: imageSection,
          ),
        ),
        const SizedBox(height: 14),
        details,
      ],
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final hasControls =
        _faces.length > 1 || _hasVariantPicker || _hasLanguagePicker;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CardDetailMedia(imageUrl: _imageUrl),
        if (hasControls) ...[
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_faces.length > 1) _buildFaceNavigation(),
              if (_faces.length > 1 &&
                  (_hasVariantPicker || _hasLanguagePicker))
                const SizedBox(width: 4),
              if (_hasVariantPicker)
                buildVariantButton(
                  onPressed: _showVariantPicker,
                  tooltip: appLocalizations.translate(
                    'card_detail.choose_variant',
                  ),
                ),
              if (_hasLanguagePicker) ...[
                const SizedBox(width: 4),
                buildLanguageButton(
                  onPressed: _showLanguagePicker,
                  tooltip: appLocalizations.translate(
                    'card_detail.choose_language',
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFaceNavigation() {
    return CardDetailFaceNavigation(
      faceIndex: _faceIndex,
      faceCount: _faces.length,
      onPrevious: _faceIndex == 0 ? null : () => setState(() => _faceIndex--),
      onNext: _faceIndex == _faces.length - 1
          ? null
          : () => setState(() => _faceIndex++),
      previousTooltip: appLocalizations.translate('card_detail.previous_face'),
      nextTooltip: appLocalizations.translate('card_detail.next_face'),
    );
  }

  Widget _buildSearchActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showActionPlaceholder(
              appLocalizations.translate('card_detail.add_to_deck'),
            ),
            icon: const Icon(Icons.playlist_add),
            label: Text(appLocalizations.translate('card_detail.add_to_deck')),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _showActionPlaceholder(
              appLocalizations.translate('card_detail.add_to_collection'),
            ),
            icon: const Icon(Icons.add),
            label: Text(
              appLocalizations.translate('card_detail.add_to_collection'),
            ),
          ),
        ),
      ],
    );
  }

  void _showActionPlaceholder(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${appLocalizations.translate('card_detail.action_placeholder')}: $action',
        ),
      ),
    );
  }

  Future<void> _showVariantPicker() async {
    final selectedIndex = await showCardVariantPicker(
      context: context,
      variants: _languageVariants,
      variantFaces: widget.variantFaces,
      selectedIndex: _variantIndex,
    );

    if (!mounted || selectedIndex == null || selectedIndex == _variantIndex) {
      return;
    }

    setState(() {
      _variantIndex = selectedIndex;
      _faceIndex = 0;
    });
  }

  Future<void> _showLanguagePicker() async {
    final selectedLanguage = await showCardLanguagePicker(
      context: context,
      languages: _availableLanguages,
      selectedLanguage: _selectedLanguage,
    );

    if (!mounted ||
        selectedLanguage == null ||
        selectedLanguage == _selectedLanguage) {
      return;
    }

    setState(() {
      _selectedLanguage = selectedLanguage;
      _variantIndex = 0;
      _faceIndex = 0;
    });
  }
}

// =============================================================================
// Card details
// =============================================================================

/// Renders the selected face's text, stats, legalities, and metadata.
class CardDetailInfo extends StatelessWidget {
  const CardDetailInfo({
    required this.card,
    this.face,
    this.showLegalities = true,
    this.showMetadata = true,
    super.key,
  });

  final ScryfallCard card;
  final ScryfallCardFace? face;
  final bool showLegalities;
  final bool showMetadata;

  String get _name => face?.name ?? card.name;
  String? get _manaCost => face?.manaCost ?? card.manaCost;
  String get _typeLine => face?.typeLine ?? card.typeLine;
  String? get _oracleText => face?.oracleText ?? card.oracleText;
  String? get _printedText => face?.printedText ?? card.printedText;
  String? get _power => face?.power ?? card.power;
  String? get _toughness => face?.toughness ?? card.toughness;
  String? get _loyalty => face?.loyalty ?? card.loyalty;
  String? get _defense => face?.defense ?? card.defense;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final info = <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              _name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.headlineMedium,
            ),
          ),
          if (_hasValue(_manaCost)) ...[
            const SizedBox(width: 8),
            ScryfallSymbolText(text: _manaCost!, style: textTheme.titleMedium),
          ],
        ],
      ),
      const CardDetailSectionDivider(),
      Text(_typeLine, style: textTheme.titleMedium),
      const CardDetailSectionDivider(),
    ];

    final cardText = _oracleText ?? _printedText;
    if (_hasValue(cardText)) {
      info.add(ScryfallSymbolText(text: cardText!, symbolScale: 0.82));
    }

    final stats = _buildStats();
    if (stats != null) {
      info.addAll([
        const CardDetailSectionDivider(),
        Text(stats, style: textTheme.titleMedium),
      ]);
    }

    final metadata = _metadata();
    if (showLegalities) {
      info.addAll([
        const CardDetailSectionDivider(),
        _LegalitiesGrid(card: card),
      ]);
    } else if (showMetadata && metadata.isNotEmpty) {
      info.add(const CardDetailSectionDivider());
    }

    if (showMetadata && metadata.isNotEmpty) {
      if (showLegalities) info.add(const CardDetailSectionDivider());
      info.add(Text(metadata.join('  |  '), style: textTheme.bodySmall));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: info,
    );
  }

  String? _buildStats() {
    final stats = <String>[];
    if (_hasValue(_power) && _hasValue(_toughness)) {
      stats.add(
        '${appLocalizations.translate('card_detail.power_toughness')}: $_power/$_toughness',
      );
    }
    if (_hasValue(_loyalty)) {
      stats.add(
        '${appLocalizations.translate('card_detail.loyalty')}: $_loyalty',
      );
    }
    if (_hasValue(_defense)) {
      stats.add(
        '${appLocalizations.translate('card_detail.defense')}: $_defense',
      );
    }

    return stats.isEmpty ? null : stats.join('  |  ');
  }

  List<String> _metadata() {
    return [
      if (_hasValue(card.setName)) card.setName,
      if (_hasValue(card.rarity)) card.rarity,
      if (_hasValue(card.collectorNumber))
        '${appLocalizations.translate('card_detail.collector_number')}: ${card.collectorNumber}',
      if (_hasValue(card.artist))
        '${appLocalizations.translate('card_detail.illustrated_by')} ${card.artist}',
    ];
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;
}

class _LegalitiesGrid extends StatelessWidget {
  const _LegalitiesGrid({required this.card});

  final ScryfallCard card;

  @override
  Widget build(BuildContext context) {
    final legalities = <String, String?>{
      appLocalizations.translate('card_detail.formats.standard'):
          card.legalStandard,
      appLocalizations.translate('card_detail.formats.future'):
          card.legalFuture,
      appLocalizations.translate('card_detail.formats.historic'):
          card.legalHistoric,
      appLocalizations.translate('card_detail.formats.timeless'):
          card.legalTimeless,
      appLocalizations.translate('card_detail.formats.pioneer'):
          card.legalPioneer,
      appLocalizations.translate('card_detail.formats.modern'):
          card.legalModern,
      appLocalizations.translate('card_detail.formats.legacy'):
          card.legalLegacy,
      appLocalizations.translate('card_detail.formats.pauper'):
          card.legalPauper,
      appLocalizations.translate('card_detail.formats.vintage'):
          card.legalVintage,
      appLocalizations.translate('card_detail.formats.commander'):
          card.legalCommander,
      appLocalizations.translate('card_detail.formats.oathbreaker'):
          card.legalOathbreaker,
      appLocalizations.translate('card_detail.formats.brawl'): card.legalBrawl,
      appLocalizations.translate('card_detail.formats.alchemy'):
          card.legalAlchemy,
      appLocalizations.translate('card_detail.formats.duel'): card.legalDuel,
      appLocalizations.translate('card_detail.formats.old_school'):
          card.legalOldSchool,
      appLocalizations.translate('card_detail.formats.premodern'):
          card.legalPremodern,
    };

    if (legalities.values.any((status) => status == 'unreleased')) {
      return Text(
        appLocalizations.translate('card_detail.unreleased'),
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final rows = legalities.entries
        .where((entry) => entry.value?.trim().isNotEmpty ?? false)
        .toList();
    if (rows.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 120,
        mainAxisExtent: 28,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemBuilder: (context, index) =>
          _LegalityTile(format: rows[index].key, status: rows[index].value!),
    );
  }
}

class _LegalityTile extends StatelessWidget {
  const _LegalityTile({required this.format, required this.status});

  final String format;
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'legal' => Colors.green.shade700,
      'banned' => Colors.red.shade700,
      _ => Colors.grey.shade600,
    };

    return Tooltip(
      message: appLocalizations.translate('card_detail.status.$status'),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          format,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Media and navigation
// =============================================================================

/// Displays the current card image with loading and error fallbacks.
class CardDetailMedia extends StatelessWidget {
  const CardDetailMedia({required this.imageUrl, super.key});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.716,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: imageUrl == null
            ? const ColoredBox(
                color: Colors.black12,
                child: Center(child: Icon(Icons.image_not_supported_outlined)),
              )
            : CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.contain,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const ColoredBox(
                  color: Colors.black12,
                  child: Center(child: Icon(Icons.broken_image_outlined)),
                ),
              ),
      ),
    );
  }
}

/// Provides previous and next controls for a multi-face card.
class CardDetailFaceNavigation extends StatelessWidget {
  const CardDetailFaceNavigation({
    required this.faceIndex,
    required this.faceCount,
    required this.onPrevious,
    required this.onNext,
    required this.previousTooltip,
    required this.nextTooltip,
    super.key,
  });

  final int faceIndex;
  final int faceCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String previousTooltip;
  final String nextTooltip;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: previousTooltip,
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          '${faceIndex + 1} / $faceCount',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        IconButton(
          tooltip: nextTooltip,
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class CardDetailSectionDivider extends StatelessWidget {
  const CardDetailSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 1),
    );
  }
}

// =============================================================================
// Pickers and context-specific actions
// =============================================================================

/// Shows the printed variants for the currently selected language.
Future<int?> showCardVariantPicker({
  required BuildContext context,
  required List<ScryfallCard> variants,
  required Map<String, List<ScryfallCardFace>> variantFaces,
  required int selectedIndex,
}) {
  return showModalBottomSheet<int>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: variants.length,
          itemBuilder: (context, index) {
            final variant = variants[index];
            final previewUrl =
                variant.imageSmall ??
                (variantFaces[variant.scryfallId]?.isNotEmpty ?? false
                    ? variantFaces[variant.scryfallId]!.first.imageSmall
                    : null);
            return ListTile(
              selected: index == selectedIndex,
              leading: previewUrl == null
                  ? const Icon(Icons.image_outlined)
                  : Image.network(
                      previewUrl,
                      width: 36,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
              title: Text(variant.name),
              subtitle: Text(variant.setName),
              onTap: () => Navigator.of(context).pop(index),
            );
          },
        ),
      );
    },
  );
}

/// Shows the languages available across the card's printed variants.
Future<String?> showCardLanguagePicker({
  required BuildContext context,
  required List<String> languages,
  required String selectedLanguage,
}) {
  return showModalBottomSheet<String>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: languages.length,
          itemBuilder: (context, index) {
            final language = languages[index];
            return ListTile(
              selected: language == selectedLanguage,
              leading: const Icon(Icons.language),
              title: Text(language.toUpperCase()),
              onTap: () => Navigator.of(context).pop(language),
            );
          },
        ),
      );
    },
  );
}

/// Builds the search-only printed variant action button.
Widget buildVariantButton({
  required VoidCallback onPressed,
  required String tooltip,
}) {
  return IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    icon: const Icon(Icons.cyclone_outlined),
  );
}

/// Builds the search-only language action button.
Widget buildLanguageButton({
  required VoidCallback onPressed,
  required String tooltip,
}) {
  return IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    icon: const Icon(Icons.language),
  );
}
