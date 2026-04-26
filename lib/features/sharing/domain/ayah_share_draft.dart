import 'package:flutter/foundation.dart';

import '../../quran/domain/quran_position.dart';

enum ShareFormat { text, squareImage, storyImage, portraitImage }

enum ShareTheme { light, night, parchment }

enum BrandPlacement { footer, minimal }

@immutable
class AyahShareDraft {
  const AyahShareDraft({
    required this.id,
    required this.position,
    required this.format,
    this.includeTranslation = false,
    this.includeTafsir = false,
    this.theme = ShareTheme.light,
    this.brandPlacement = BrandPlacement.footer,
    required this.createdAt,
    required this.updatedAt,
    this.lastGeneratedPathOrUri,
  });

  final String id;
  final QuranPosition position;
  final ShareFormat format;
  final bool includeTranslation;
  final bool includeTafsir;
  final ShareTheme theme;
  final BrandPlacement brandPlacement;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastGeneratedPathOrUri;

  @override
  bool operator ==(Object other) => other is AyahShareDraft && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
