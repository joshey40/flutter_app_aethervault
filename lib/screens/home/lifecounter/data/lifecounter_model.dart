import 'dart:convert';

class LifecounterGame {
  final int startLife;
  final int playerCount;
  final List<int> currentLives;
  final List<int> commanderTax;
  final List<List<List<int>>> commanderDamage;
  final List<bool> partnerEnabled;
  final List<int> partnerTax;
  final bool active;
  final String? name;

  LifecounterGame({
    required this.startLife,
    required this.playerCount,
    required this.currentLives,
    List<int>? commanderTax,
    List<List<List<int>>>? commanderDamage,
    List<bool>? partnerEnabled,
    List<int>? partnerTax,
    this.active = true,
    this.name,
  }) : commanderTax = commanderTax ?? List<int>.filled(playerCount, 0),
      commanderDamage = commanderDamage ?? List<List<List<int>>>.generate(playerCount, (_) => List<List<int>>.generate(playerCount, (_) => [0])),
      partnerEnabled = partnerEnabled ?? List<bool>.filled(playerCount, false),
      partnerTax = partnerTax ?? List<int>.filled(playerCount, 0);
      

  Map<String, dynamic> toJson() => {
        'startLife': startLife,
        'playerCount': playerCount,
        'currentLives': currentLives,
      'commanderTax': commanderTax,
      'commanderDamage': commanderDamage,
      'partnerEnabled': partnerEnabled,
      'partnerTax': partnerTax,
        'active': active,
        'name': name,
      };

  // Deserialize JSON into a LifecounterGame.
  // Ensure that lists (`currentLives` and `commanderTax`) always match `playerCount`.
  factory LifecounterGame.fromJson(Map<String, dynamic> json) {
    final startLife = json['startLife'] as int? ?? 20;
    final playerCount = json['playerCount'] as int? ?? 2;

    // Safely decode currentLives and normalize length to playerCount.
    final currentLivesRaw = (json['currentLives'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [];
    final currentLives = List<int>.from(currentLivesRaw);
    if (currentLives.length < playerCount) {
      // If stored list is shorter, fill remaining players with startLife.
      currentLives.addAll(List<int>.filled(playerCount - currentLives.length, startLife));
    } else if (currentLives.length > playerCount) {
      // If stored list is longer, truncate to match playerCount.
      currentLives.removeRange(playerCount, currentLives.length);
    }

    // Safely decode commanderTax and normalize length to playerCount.
    final commanderTaxRaw = (json['commanderTax'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [];
    final commanderTax = List<int>.from(commanderTaxRaw);
    if (commanderTax.length < playerCount) {
      commanderTax.addAll(List<int>.filled(playerCount - commanderTax.length, 0));
    } else if (commanderTax.length > playerCount) {
      commanderTax.removeRange(playerCount, commanderTax.length);
    }

    // Safely decode partnerEnabled and normalize length to playerCount.
    final partnerRaw = (json['partnerEnabled'] as List<dynamic>?)?.map((e) => e as bool).toList() ?? [];
    final partnerEnabled = List<bool>.from(partnerRaw);
    if (partnerEnabled.length < playerCount) {
      partnerEnabled.addAll(List<bool>.filled(playerCount - partnerEnabled.length, false));
    } else if (partnerEnabled.length > playerCount) {
      partnerEnabled.removeRange(playerCount, partnerEnabled.length);
    }

    // Safely decode partnerTax and normalize length to playerCount.
    final partnerTaxRaw = (json['partnerTax'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [];
    final partnerTax = List<int>.from(partnerTaxRaw);
    if (partnerTax.length < playerCount) {
      partnerTax.addAll(List<int>.filled(playerCount - partnerTax.length, 0));
    } else if (partnerTax.length > playerCount) {
      partnerTax.removeRange(playerCount, partnerTax.length);
    }

    // Safely decode commanderDamage: nested list [source][target] -> [slot0, slot1]
    final commanderDamageRaw = (json['commanderDamage'] as List<dynamic>?) ?? [];
    final List<List<List<int>>> commanderDamage = List<List<List<int>>>.generate(playerCount, (s) {
      final sourceRaw = (s < commanderDamageRaw.length ? commanderDamageRaw[s] as List<dynamic>? : null) ?? [];
      return List<List<int>>.generate(playerCount, (t) {
        final targetRaw = (t < sourceRaw.length ? (sourceRaw[t] as List<dynamic>?) : null) ?? [];
        final values = targetRaw.map((e) => e as int).toList();
        final numSlots = (partnerEnabled.length > t && partnerEnabled[t]) ? 2 : 1;
        final list = List<int>.from(values);
        if (list.length < numSlots) list.addAll(List<int>.filled(numSlots - list.length, 0));
        // Keep extra slots if present so partner damage isn't lost when partner is toggled off.
        return list;
      });
    });

    final active = json['active'] as bool? ?? false;
    final name = json['name'] as String?;

    return LifecounterGame(
      startLife: startLife,
      playerCount: playerCount,
      currentLives: currentLives,
      commanderTax: commanderTax,
      commanderDamage: commanderDamage,
      partnerEnabled: partnerEnabled,
      partnerTax: partnerTax,
      active: active,
      name: name,
    );
  }

  String encode() => json.encode(toJson());

  static LifecounterGame? decode(String? data) {
    if (data == null) return null;
    try {
      final Map<String, dynamic> map = json.decode(data) as Map<String, dynamic>;
      final game = LifecounterGame.fromJson(map);
      game.validate();
      return game;
    } catch (_) {
      return null;
    }
  }

  /// Validate internal consistency of the model.
  /// Throws [FormatException] when validation fails.
  void validate() {
    if (playerCount <= 0) throw FormatException('playerCount must be > 0');
    if (startLife <= 0) throw FormatException('startLife must be > 0');
    if (currentLives.length != playerCount) throw FormatException('currentLives length must equal playerCount');
    if (commanderTax.length != playerCount) throw FormatException('commanderTax length must equal playerCount');
    if (partnerEnabled.length != playerCount) throw FormatException('partnerEnabled length must equal playerCount');
    if (partnerTax.length != playerCount) throw FormatException('partnerTax length must equal playerCount');

    if (commanderDamage.length != playerCount) throw FormatException('commanderDamage outer length must equal playerCount');
    for (var s = 0; s < commanderDamage.length; s++) {
      final row = commanderDamage[s];
      if (row.length != playerCount) throw FormatException('commanderDamage[$s] length must equal playerCount');
      for (var t = 0; t < row.length; t++) {
        final slots = row[t];
        final expectedSlots = (t < partnerEnabled.length && partnerEnabled[t]) ? 2 : 1;
        // Allow extra slots to preserve partner damage when partner was temporarily disabled.
        if (slots.length < expectedSlots) throw FormatException('commanderDamage[$s][$t] must have at least $expectedSlots slots');
      }
    }
  }

  /// Ensure all commanderDamage[source][target] slot lists match
  /// at least the expected number of slots for the target (1 or 2 depending on partnerEnabled).
  /// Preserves extra slots so partner damage isn't lost.
  void normalizeCommanderDamageSlots() {
    final pc = playerCount;
    // Ensure outer structure
    while (commanderDamage.length < pc) {
      commanderDamage.add(List<List<int>>.generate(pc, (_) => [0]));
    }
    for (var s = 0; s < pc; s++) {
      final row = commanderDamage[s];
      // Ensure row length equals playerCount
      while (row.length < pc) {
        row.add([0]);
      }
      if (row.length > pc) {
        row.removeRange(pc, row.length);
      }
      for (var t = 0; t < pc; t++) {
        final expectedSlots = (partnerEnabled.length > t && partnerEnabled[t]) ? 2 : 1;
        final slots = row[t];
        if (slots.length < expectedSlots) {
          slots.addAll(List<int>.filled(expectedSlots - slots.length, 0));
        }
        // do not remove extra slots: preserve partner damage
      }
    }
  }
}
