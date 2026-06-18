import 'package:flutter/material.dart';

/// Single source of truth for resolving a vibhag's icon key and hex colour
/// (both supplied by the backend) into Flutter types. Shared by the Vibhags
/// hub, vibhag detail and every event surface so the mapping is never
/// duplicated.
class VibhagVisuals {
  VibhagVisuals._();

  static const _icons = <String, IconData>{
    'local_fire_department': Icons.local_fire_department_rounded,
    'spa': Icons.spa_rounded,
    'music_note': Icons.music_note_rounded,
    'checkroom': Icons.checkroom_rounded,
    'volunteer_activism': Icons.volunteer_activism_rounded,
    'eco': Icons.eco_rounded,
    'event': Icons.event_rounded,
  };

  static IconData icon(String? key) => _icons[key] ?? Icons.event_rounded;

  /// Parses '#2992D6' (or 'AARRGGBB' / 'RRGGBB') into a [Color].
  static Color color(String? hex, {Color fallback = const Color(0xFF2992D6)}) {
    if (hex == null || hex.isEmpty) return fallback;
    var value = hex.replaceFirst('#', '').trim();
    if (value.length == 6) value = 'FF$value';
    final parsed = int.tryParse(value, radix: 16);
    return parsed == null ? fallback : Color(parsed);
  }
}
