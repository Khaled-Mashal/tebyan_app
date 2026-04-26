import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tebyan_app/features/quran/domain/quran_position.dart';
import 'package:tebyan_app/features/quran/infrastructure/quran_gateway.dart';
import 'package:tebyan_app/features/sharing/application/ayah_sharing_service.dart';
import 'package:tebyan_app/features/sharing/domain/ayah_share_draft.dart';
import 'package:tebyan_app/shared/platform/share_gateway.dart';

void main() {
  group('AyahSharingService', () {
    late _FakeSelectionGateway selectionGateway;
    late _FakeShareGateway shareGateway;
    late AyahSharingService service;

    setUp(() {
      selectionGateway = _FakeSelectionGateway();
      shareGateway = _FakeShareGateway();
      service = AyahSharingService(
        selectionGateway: selectionGateway,
        shareGateway: shareGateway,
      );
    });

    group('generateShareText', () {
      test('returns text reference from selection gateway', () async {
        selectionGateway.shareTextResult =
            'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ\nالفاتحة 1:1';

        final result = await service.generateShareText(_fatihahPos);

        expect(result.isSuccess, isTrue);
        result.fold(
          onSuccess: (text) {
            expect(text, contains('بِسْمِ اللَّهِ'));
            expect(text, contains('الفاتحة'));
          },
          onFailure: (_) => fail('Expected success'),
        );
      });

      test('passes correct position to selection gateway', () async {
        await service.generateShareText(_fatihahPos);

        expect(selectionGateway.requestedPositions, hasLength(1));
        expect(selectionGateway.requestedPositions.single.surahNumber, 1);
        expect(selectionGateway.requestedPositions.single.page, 1);
      });

      test('returns failure when selection gateway throws', () async {
        selectionGateway.shouldThrow = true;

        final result = await service.generateShareText(_fatihahPos);

        expect(result.isFailure, isTrue);
      });
    });

    group('shareAyahText', () {
      test('calls share gateway with generated text', () async {
        selectionGateway.shareTextResult = 'نص آية اختباري\n1:1';

        final result = await service.shareAyahText(_fatihahPos);

        expect(result.isSuccess, isTrue);
        expect(shareGateway.sharedTexts, hasLength(1));
        expect(shareGateway.sharedTexts.single, contains('نص آية اختباري'));
      });

      test('does not call share gateway when text generation fails', () async {
        selectionGateway.shouldThrow = true;

        await service.shareAyahText(_fatihahPos);

        expect(shareGateway.sharedTexts, isEmpty);
      });

      test('returns failure when share gateway throws', () async {
        shareGateway.shouldThrow = true;

        final result = await service.shareAyahText(_fatihahPos);

        expect(result.isFailure, isTrue);
      });
    });

    group('shareAyahImage', () {
      test('returns failure when draft has no generated image', () async {
        final draft = AyahShareDraft(
          id: 'draft-1',
          position: _fatihahPos,
          format: ShareFormat.squareImage,
          theme: ShareTheme.parchment,
          createdAt: DateTime.utc(2026, 4, 25),
          updatedAt: DateTime.utc(2026, 4, 25),
        );

        final result = await service.shareAyahImage(draft);

        expect(result.isFailure, isTrue);
      });

      test('calls share gateway with image file when draft has path', () async {
        final draft = AyahShareDraft(
          id: 'draft-2',
          position: _fatihahPos,
          format: ShareFormat.squareImage,
          theme: ShareTheme.light,
          lastGeneratedPathOrUri: '/tmp/raqeem_share.png',
          createdAt: DateTime.utc(2026, 4, 25),
          updatedAt: DateTime.utc(2026, 4, 25),
        );

        final result = await service.shareAyahImage(draft);

        expect(result.isSuccess, isTrue);
        expect(shareGateway.sharedFiles, hasLength(1));
        expect(
          shareGateway.sharedFiles.single.single.path,
          '/tmp/raqeem_share.png',
        );
      });

      test('returns failure when share gateway throws for image', () async {
        shareGateway.shouldThrow = true;
        final draft = AyahShareDraft(
          id: 'draft-3',
          position: _fatihahPos,
          format: ShareFormat.storyImage,
          theme: ShareTheme.night,
          lastGeneratedPathOrUri: '/tmp/raqeem_share.png',
          createdAt: DateTime.utc(2026, 4, 25),
          updatedAt: DateTime.utc(2026, 4, 25),
        );

        final result = await service.shareAyahImage(draft);

        expect(result.isFailure, isTrue);
      });
    });

    group('image draft options', () {
      test('square image format is preserved in draft', () {
        final draft = AyahShareDraft(
          id: 'd1',
          position: _fatihahPos,
          format: ShareFormat.squareImage,
          theme: ShareTheme.parchment,
          createdAt: DateTime.utc(2026, 4, 25),
          updatedAt: DateTime.utc(2026, 4, 25),
        );

        expect(draft.format, ShareFormat.squareImage);
      });

      test('story image format with translation and tafsir', () {
        final draft = AyahShareDraft(
          id: 'd2',
          position: _fatihahPos,
          format: ShareFormat.storyImage,
          includeTranslation: true,
          includeTafsir: true,
          theme: ShareTheme.night,
          brandPlacement: BrandPlacement.minimal,
          createdAt: DateTime.utc(2026, 4, 25),
          updatedAt: DateTime.utc(2026, 4, 25),
        );

        expect(draft.format, ShareFormat.storyImage);
        expect(draft.includeTranslation, isTrue);
        expect(draft.includeTafsir, isTrue);
        expect(draft.theme, ShareTheme.night);
        expect(draft.brandPlacement, BrandPlacement.minimal);
      });

      test('portrait image format with light theme', () {
        final draft = AyahShareDraft(
          id: 'd3',
          position: _fatihahPos,
          format: ShareFormat.portraitImage,
          theme: ShareTheme.light,
          createdAt: DateTime.utc(2026, 4, 25),
          updatedAt: DateTime.utc(2026, 4, 25),
        );

        expect(draft.format, ShareFormat.portraitImage);
        expect(draft.theme, ShareTheme.light);
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

class _FakeSelectionGateway implements QuranSelectionGateway {
  final List<QuranPosition> requestedPositions = [];
  String shareTextResult = '';
  bool shouldThrow = false;

  @override
  Future<SelectedAyah> getSelectedAyah(QuranPosition position) async {
    requestedPositions.add(position);
    if (shouldThrow) throw Exception('فشل في الحصول على الآية');
    return SelectedAyah(
      position: position,
      text: 'نص آية اختباري',
      reference: '${position.surahNumber}:${position.ayahNumber}',
    );
  }

  @override
  Future<String> buildShareText(
    QuranPosition position, {
    String? translationId,
  }) async {
    requestedPositions.add(position);
    if (shouldThrow) throw Exception('فشل في إنشاء نص المشاركة');
    return shareTextResult;
  }

  @override
  Future<void> copyAyah(QuranPosition position) async {}
}

class _FakeShareGateway implements ShareGateway {
  final List<String> sharedTexts = [];
  final List<List<ShareFile>> sharedFiles = [];
  bool shouldThrow = false;

  @override
  Future<ShareResult> shareText({
    required String text,
    String? subject,
    String? title,
  }) async {
    if (shouldThrow) throw Exception('فشل المشاركة');
    sharedTexts.add(text);
    return ShareResult('', ShareResultStatus.success);
  }

  @override
  Future<ShareResult> shareFiles({
    required List<ShareFile> files,
    String? text,
    String? subject,
    String? title,
  }) async {
    if (shouldThrow) throw Exception('فشل مشاركة الملف');
    sharedFiles.add(files);
    return ShareResult('', ShareResultStatus.success);
  }
}
