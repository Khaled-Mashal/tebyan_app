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
        QuranSearchGateway,
        QuranAudioGateway,
        QuranWordGateway {
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
  Future<QuranPosition> resolveAyahPosition(int ayahUQNumber);
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

abstract interface class QuranAudioGateway {
  Future<void> playAyahAudio(
    BuildContext context,
    QuranPosition position, {
    bool playSingleAyah = true,
  });
}

abstract interface class QuranWordGateway {
  Future<List<QuranAyahWord>> getAyahWords(QuranPosition position);
  Future<void> playWordAudio(QuranWordSelection selection);
  Future<void> playAyahWordsAudio(QuranPosition position);
  Future<QuranWordInfoResult> getWordInfo(
    QuranWordSelection selection, {
    QuranWordInfoKind kind = QuranWordInfoKind.recitations,
  });
  Future<AvailabilityState> downloadWordInfoKind(QuranWordInfoKind kind);
  Future<void> showWordInfo(
    BuildContext context,
    QuranWordSelection selection, {
    QuranWordInfoKind kind = QuranWordInfoKind.recitations,
  });
}

abstract interface class QuranExplanationGateway {
  Future<List<TafsirSourceSummary>> listTafsirSources();
  Future<List<TranslationSourceSummary>> listTranslationSources();
  Future<List<QuranExplanationText>> getTafsir(
    QuranPosition position, {
    String? sourceId,
  });
  Future<List<QuranExplanationText>> getTranslation(
    QuranPosition position, {
    String? sourceId,
  });
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

class QuranAyahWord {
  const QuranAyahWord({required this.selection, required this.text});

  final QuranWordSelection selection;
  final String text;
}

class QuranWordSelection {
  const QuranWordSelection({required this.position, required this.wordNumber});

  final QuranPosition position;
  final int wordNumber;
}

enum QuranWordInfoKind { recitations, morphology, grammar }

class QuranWordInfoResult {
  const QuranWordInfoResult({
    required this.kind,
    required this.availability,
    this.word,
    this.content,
    this.hasKhilaf = false,
  });

  final QuranWordInfoKind kind;
  final AvailabilityState availability;
  final String? word;
  final String? content;
  final bool hasKhilaf;

  bool get hasContent => content != null && content!.trim().isNotEmpty;
}

class QuranExplanationText {
  const QuranExplanationText({
    required this.sourceId,
    required this.sourceName,
    required this.text,
    this.availability = AvailabilityState.available,
  });

  final String sourceId;
  final String sourceName;
  final String text;
  final AvailabilityState availability;

  bool get hasContent => text.trim().isNotEmpty;
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
