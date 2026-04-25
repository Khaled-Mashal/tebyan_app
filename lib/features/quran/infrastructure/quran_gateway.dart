import 'package:flutter/widgets.dart';

import '../../../shared/errors/app_error.dart';
import '../../../shared/errors/result.dart';
import '../domain/quran_position.dart';

abstract class QuranGateway
    implements
        QuranNavigationGateway,
        QuranSelectionGateway,
        QuranExplanationGateway,
        QuranBookmarkGateway,
        QuranSearchGateway {
  Future<void> initialize({
    required String languageCode,
    required bool enableWordAudio,
    Map<int, List<Object>>? initialBookmarkAnchors,
  });

  Future<Result<void>> initializeSafely({
    required String languageCode,
    required bool enableWordAudio,
    Map<int, List<Object>>? initialBookmarkAnchors,
  }) {
    return guardResult<void>(
      () => initialize(
        languageCode: languageCode,
        enableWordAudio: enableWordAudio,
        initialBookmarkAnchors: initialBookmarkAnchors,
      ),
      code: AppErrorCode.startup,
      message: 'تعذر بدء مكتبة القرآن.',
    );
  }

  bool get isInitialized;
}

abstract interface class QuranNavigationGateway {
  Future<QuranPosition> resolvePageStart(int page);
  Future<QuranPosition> resolveSurahStart(int surahNumber);
  Future<QuranPosition> resolveJuzStart(int juzNumber);
  Future<QuranPosition> resolveHizbStart(int hizbNumber);
  Future<QuranPosition> resolveRubStart(int rubNumber);
  Future<int> comparePositions(QuranPosition a, QuranPosition b);

  void jumpToPosition(QuranPosition position);
  void jumpToPage(int page);
  void jumpToSurah(int surahNumber);
  void jumpToJuz(int juzNumber);
  void jumpToHizb(int hizbNumber);
}

abstract interface class QuranSelectionGateway {
  Future<SelectedAyah> getSelectedAyah(QuranPosition position);
  Future<String> buildShareText(
    QuranPosition position, {
    String? translationId,
  });
  Future<void> copyAyah(QuranPosition position);
}

abstract interface class QuranExplanationGateway {
  Future<List<TafsirSourceSummary>> listTafsirSources();
  Future<List<TranslationSourceSummary>> listTranslationSources();
  Future<AvailabilityState> ensureTafsirAvailable(String sourceId);
  Future<AvailabilityState> ensureTranslationAvailable(String sourceId);
  Future<void> showTafsir(BuildContext context, QuranPosition position);
  Future<void> showTranslation(BuildContext context, QuranPosition position);
}

abstract interface class QuranBookmarkGateway {
  Future<int?> createOrUpdateAnchor(QuranBookmarkAnchorInput annotation);
  Future<void> removeAnchor(int quranLibraryBookmarkId);
  Future<void> jumpToAnchor(int quranLibraryBookmarkId, QuranPosition fallback);
}

abstract interface class QuranSearchGateway {
  Future<List<QuranSearchMatch>> searchAyahs(String query);
  Future<List<QuranSearchMatch>> searchSurahs(String query);
  Future<List<QuranSearchMatch>> searchAvailableTafsir(String query);
}

enum AvailabilityState { available, downloading, unavailable, unsupported }

class SelectedAyah {
  const SelectedAyah({
    required this.position,
    required this.text,
    required this.reference,
    this.translation,
    this.tafsir,
  });

  final QuranPosition position;
  final String text;
  final String reference;
  final String? translation;
  final String? tafsir;
}

class TafsirSourceSummary {
  const TafsirSourceSummary({
    required this.id,
    required this.displayName,
    required this.availability,
  });

  final String id;
  final String displayName;
  final AvailabilityState availability;
}

class TranslationSourceSummary {
  const TranslationSourceSummary({
    required this.id,
    required this.displayName,
    required this.availability,
  });

  final String id;
  final String displayName;
  final AvailabilityState availability;
}

class QuranBookmarkAnchorInput {
  const QuranBookmarkAnchorInput({
    required this.id,
    required this.position,
    required this.displayName,
    required this.colorValue,
    this.existingAnchorId,
  });

  final String id;
  final QuranPosition position;
  final String displayName;
  final int colorValue;
  final int? existingAnchorId;
}

enum QuranSearchMatchSource { ayah, surah, tafsir }

class QuranSearchMatch {
  const QuranSearchMatch({
    required this.id,
    required this.source,
    required this.title,
    this.snippet,
    this.position,
    this.availability = AvailabilityState.available,
  });

  final String id;
  final QuranSearchMatchSource source;
  final String title;
  final String? snippet;
  final QuranPosition? position;
  final AvailabilityState availability;
}
