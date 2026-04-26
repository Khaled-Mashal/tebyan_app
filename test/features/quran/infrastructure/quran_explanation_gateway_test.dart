import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tebyan_app/features/quran/domain/quran_position.dart';
import 'package:tebyan_app/features/quran/infrastructure/quran_gateway.dart';

void main() {
  group('QuranExplanationGateway', () {
    late _ConfigurableExplanationGateway gateway;

    setUp(() {
      gateway = _ConfigurableExplanationGateway();
    });

    group('listTafsirSources', () {
      test('returns available tafsir source summaries', () async {
        gateway.tafsirSources = const [
          TafsirSourceSummary(
            id: 'muyassar',
            displayName: 'التفسير الميسر',
            availability: AvailabilityState.available,
          ),
          TafsirSourceSummary(
            id: 'ibn-katheer',
            displayName: 'تفسير ابن كثير',
            availability: AvailabilityState.downloading,
          ),
        ];

        final sources = await gateway.listTafsirSources();

        expect(sources, hasLength(2));
        expect(sources[0].id, 'muyassar');
        expect(sources[0].displayName, 'التفسير الميسر');
        expect(sources[0].availability, AvailabilityState.available);
        expect(sources[1].availability, AvailabilityState.downloading);
      });

      test('returns empty list when no tafsir sources are available', () async {
        final sources = await gateway.listTafsirSources();

        expect(sources, isEmpty);
      });
    });

    group('listTranslationSources', () {
      test('returns available translation source summaries', () async {
        gateway.translationSources = const [
          TranslationSourceSummary(
            id: 'en-sahih',
            displayName: 'Saheeh International',
            availability: AvailabilityState.available,
          ),
        ];

        final sources = await gateway.listTranslationSources();

        expect(sources, hasLength(1));
        expect(sources.single.id, 'en-sahih');
        expect(sources.single.availability, AvailabilityState.available);
      });

      test('returns empty list when no translation sources exist', () async {
        final sources = await gateway.listTranslationSources();

        expect(sources, isEmpty);
      });
    });

    group('ensureTafsirAvailable', () {
      test('returns available for downloaded tafsir', () async {
        gateway.tafsirAvailability['muyassar'] = AvailabilityState.available;

        final state = await gateway.ensureTafsirAvailable('muyassar');

        expect(state, AvailabilityState.available);
      });

      test('returns downloading for tafsir in progress', () async {
        gateway.tafsirAvailability['ibn-katheer'] =
            AvailabilityState.downloading;

        final state = await gateway.ensureTafsirAvailable('ibn-katheer');

        expect(state, AvailabilityState.downloading);
      });

      test('returns unavailable for missing tafsir', () async {
        final state = await gateway.ensureTafsirAvailable('missing');

        expect(state, AvailabilityState.unavailable);
      });
    });

    group('ensureTranslationAvailable', () {
      test('returns available for downloaded translation', () async {
        gateway.translationAvailability['en-sahih'] =
            AvailabilityState.available;

        final state = await gateway.ensureTranslationAvailable('en-sahih');

        expect(state, AvailabilityState.available);
      });

      test('returns unavailable for missing translation', () async {
        final state = await gateway.ensureTranslationAvailable('missing');

        expect(state, AvailabilityState.unavailable);
      });
    });

    group('getTafsir', () {
      test('returns tafsir text entries for the requested ayah', () async {
        gateway.tafsirTexts = const [
          QuranExplanationText(
            sourceId: 'muyassar',
            sourceName: 'التفسير الميسر',
            text: 'نص التفسير',
          ),
        ];

        final entries = await gateway.getTafsir(_fatihahPos);

        expect(entries, hasLength(1));
        expect(entries.single.sourceName, 'التفسير الميسر');
        expect(entries.single.text, 'نص التفسير');
      });
    });

    group('getTranslation', () {
      test('returns translation text entries for the requested ayah', () async {
        gateway.translationTexts = const [
          QuranExplanationText(
            sourceId: 'en',
            sourceName: 'English',
            text: 'Translation text',
          ),
        ];

        final entries = await gateway.getTranslation(_baqarahPos);

        expect(entries.single.sourceId, 'en');
        expect(entries.single.text, 'Translation text');
      });
    });

    group('showTafsir', () {
      testWidgets('records the position for tafsir display', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
        );
        final context = tester.element(find.byType(SizedBox));

        await gateway.showTafsir(context, _fatihahPos);

        expect(gateway.tafsirPositions, hasLength(1));
        expect(gateway.tafsirPositions.single.surahNumber, 1);
        expect(gateway.tafsirPositions.single.page, 1);
      });

      testWidgets('showTafsir and showTranslation record separate positions', (
        tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
        );
        final context = tester.element(find.byType(SizedBox));

        await gateway.showTafsir(context, _fatihahPos);
        await gateway.showTranslation(context, _baqarahPos);

        expect(gateway.tafsirPositions, hasLength(1));
        expect(gateway.tafsirPositions.single, _fatihahPos);
        expect(gateway.translationPositions, hasLength(1));
        expect(gateway.translationPositions.single, _baqarahPos);
      });
    });

    group('showTranslation', () {
      testWidgets('records the position for translation display', (
        tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
        );
        final context = tester.element(find.byType(SizedBox));

        await gateway.showTranslation(context, _baqarahPos);

        expect(gateway.translationPositions, hasLength(1));
        expect(gateway.translationPositions.single.surahNumber, 2);
        expect(gateway.translationPositions.single.ayahNumber, 1);
      });
    });

    group('unavailable state handling', () {
      test('ensureTafsirAvailable returns unsupported when library '
          'does not expose the tafsir', () async {
        gateway.tafsirAvailability['unknown'] = AvailabilityState.unsupported;

        final state = await gateway.ensureTafsirAvailable('unknown');

        expect(state, AvailabilityState.unsupported);
      });

      test('ensureTranslationAvailable returns unsupported when library '
          'does not expose the translation', () async {
        gateway.translationAvailability['unknown'] =
            AvailabilityState.unsupported;

        final state = await gateway.ensureTranslationAvailable('unknown');

        expect(state, AvailabilityState.unsupported);
      });
    });
  });
}

final _fatihahPos = QuranPosition(
  surahNumber: 1,
  ayahNumber: 1,
  ayahUniqueNumber: 1,
  page: 1,
  juz: 1,
  hizb: 1,
  rub: 1,
  displaySurahName: 'الفاتحة',
  displayAyahLabel: 'الفاتحة ١',
);

final _baqarahPos = QuranPosition(
  surahNumber: 2,
  ayahNumber: 1,
  ayahUniqueNumber: 142,
  page: 2,
  juz: 1,
  hizb: 1,
  rub: 2,
  displaySurahName: 'البقرة',
  displayAyahLabel: 'البقرة ١',
);

class _ConfigurableExplanationGateway implements QuranExplanationGateway {
  List<TafsirSourceSummary> tafsirSources = const [];
  List<TranslationSourceSummary> translationSources = const [];
  List<QuranExplanationText> tafsirTexts = const [];
  List<QuranExplanationText> translationTexts = const [];
  Map<String, AvailabilityState> tafsirAvailability = {};
  Map<String, AvailabilityState> translationAvailability = {};
  final List<QuranPosition> tafsirPositions = [];
  final List<QuranPosition> translationPositions = [];

  @override
  Future<List<TafsirSourceSummary>> listTafsirSources() async => tafsirSources;

  @override
  Future<List<TranslationSourceSummary>> listTranslationSources() async =>
      translationSources;

  @override
  Future<AvailabilityState> ensureTafsirAvailable(String sourceId) async =>
      tafsirAvailability[sourceId] ?? AvailabilityState.unavailable;

  @override
  Future<AvailabilityState> ensureTranslationAvailable(String sourceId) async =>
      translationAvailability[sourceId] ?? AvailabilityState.unavailable;

  @override
  Future<List<QuranExplanationText>> getTafsir(
    QuranPosition position, {
    String? sourceId,
  }) async {
    tafsirPositions.add(position);
    return tafsirTexts;
  }

  @override
  Future<List<QuranExplanationText>> getTranslation(
    QuranPosition position, {
    String? sourceId,
  }) async {
    translationPositions.add(position);
    return translationTexts;
  }

  @override
  Future<void> showTafsir(BuildContext context, QuranPosition position) async {
    tafsirPositions.add(position);
  }

  @override
  Future<void> showTranslation(
    BuildContext context,
    QuranPosition position,
  ) async {
    translationPositions.add(position);
  }
}
