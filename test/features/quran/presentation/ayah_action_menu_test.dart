import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tebyan_app/app/localization/app_localizations.dart';
import 'package:tebyan_app/app/theme/raqeem_theme.dart';
import 'package:tebyan_app/features/quran/domain/quran_position.dart';
import 'package:tebyan_app/features/quran/infrastructure/quran_gateway.dart';
import 'package:tebyan_app/features/quran/presentation/ayah_action_menu.dart';

import '../../../shared/fakes/fake_quran_gateway.dart';

void main() {
  group('AyahActionMenu', () {
    late QuranPosition testPosition;

    setUp(() {
      testPosition = QuranPosition(
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
    });

    group('header display', () {
      testWidgets('shows position title with surah name and ayah number', (
        tester,
      ) async {
        await tester.pumpWidget(_AyahActionHarness(position: testPosition));
        await tester.tap(find.byKey(const Key('show_menu')));
        await tester.pumpAndSettle();

        expect(find.text('الفاتحة 1'), findsOneWidget);
      });

      testWidgets('shows close button', (tester) async {
        await tester.pumpWidget(_AyahActionHarness(position: testPosition));
        await tester.tap(find.byKey(const Key('show_menu')));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.close), findsOneWidget);
      });
    });

    group('action chips', () {
      testWidgets('shows play audio action', (tester) async {
        await tester.pumpWidget(_AyahActionHarness(position: testPosition));
        await tester.tap(find.byKey(const Key('show_menu')));
        await tester.pumpAndSettle();

        expect(find.text('تشغيل الصوت'), findsOneWidget);
      });

      testWidgets('shows tafsir action', (tester) async {
        await tester.pumpWidget(_AyahActionHarness(position: testPosition));
        await tester.tap(find.byKey(const Key('show_menu')));
        await tester.pumpAndSettle();

        expect(find.text('التفسير'), findsOneWidget);
      });

      testWidgets('shows translation action', (tester) async {
        await tester.pumpWidget(_AyahActionHarness(position: testPosition));
        await tester.tap(find.byKey(const Key('show_menu')));
        await tester.pumpAndSettle();

        expect(find.text('الترجمة'), findsOneWidget);
      });

      testWidgets('shows bookmark action', (tester) async {
        await tester.pumpWidget(_AyahActionHarness(position: testPosition));
        await tester.tap(find.byKey(const Key('show_menu')));
        await tester.pumpAndSettle();

        expect(find.text('علامة'), findsOneWidget);
      });

      testWidgets('shows add note action', (tester) async {
        await tester.pumpWidget(_AyahActionHarness(position: testPosition));
        await tester.tap(find.byKey(const Key('show_menu')));
        await tester.pumpAndSettle();

        expect(find.text('إضافة ملاحظة'), findsOneWidget);
      });

      testWidgets('shows copy text action', (tester) async {
        await tester.pumpWidget(_AyahActionHarness(position: testPosition));
        await tester.tap(find.byKey(const Key('show_menu')));
        await tester.pumpAndSettle();

        expect(find.text('نسخ'), findsOneWidget);
      });

      testWidgets('shows share text action', (tester) async {
        await tester.pumpWidget(_AyahActionHarness(position: testPosition));
        await tester.tap(find.byKey(const Key('show_menu')));
        await tester.pumpAndSettle();

        expect(find.text('مشاركة النص'), findsOneWidget);
      });

      testWidgets('shows share image action', (tester) async {
        await tester.pumpWidget(_AyahActionHarness(position: testPosition));
        await tester.tap(find.byKey(const Key('show_menu')));
        await tester.pumpAndSettle();

        expect(find.text('مشاركة صورة'), findsOneWidget);
      });
    });

    group('action callbacks', () {
      testWidgets('tapping play audio returns correct result', (tester) async {
        AyahAction? result;
        await tester.pumpWidget(
          _AyahActionHarness(
            position: testPosition,
            onResult: (r) => result = r,
          ),
        );
        await tester.tap(find.byKey(const Key('show_menu')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('تشغيل الصوت'));
        await tester.pumpAndSettle();

        expect(result, AyahAction.playAudio);
        expect(find.text('تشغيل الصوت'), findsNothing);
      });

      testWidgets('tapping tafsir returns correct result', (tester) async {
        AyahAction? result;
        await tester.pumpWidget(
          _AyahActionHarness(
            position: testPosition,
            onResult: (r) => result = r,
          ),
        );
        await tester.tap(find.byKey(const Key('show_menu')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('التفسير'));
        await tester.pumpAndSettle();

        expect(result, AyahAction.openTafsir);
      });

      testWidgets('tapping translation shows word meanings inline', (
        tester,
      ) async {
        AyahAction? result;
        await tester.pumpWidget(
          _AyahActionHarness(
            position: testPosition,
            selectedAyah: SelectedAyah(
              position: testPosition,
              text: 'نص آية اختباري',
              reference: 'الفاتحة 1:1',
            ),
            onResult: (r) => result = r,
          ),
        );
        await tester.tap(find.byKey(const Key('show_menu')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('الترجمة'));
        await tester.pumpAndSettle();

        expect(result, isNull);
        expect(find.text('الترجمة'), findsOneWidget);
        expect(find.byKey(const Key('mushaf_word_scroller')), findsOneWidget);
        expect(find.byKey(const Key('mushaf_word_meaning_1')), findsOneWidget);
      });

      testWidgets('tapping bookmark returns correct result', (tester) async {
        AyahAction? result;
        await tester.pumpWidget(
          _AyahActionHarness(
            position: testPosition,
            onResult: (r) => result = r,
          ),
        );
        await tester.tap(find.byKey(const Key('show_menu')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('علامة'));
        await tester.pumpAndSettle();

        expect(result, AyahAction.bookmark);
      });

      testWidgets('tapping add note returns correct result', (tester) async {
        AyahAction? result;
        await tester.pumpWidget(
          _AyahActionHarness(
            position: testPosition,
            onResult: (r) => result = r,
          ),
        );
        await tester.tap(find.byKey(const Key('show_menu')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('إضافة ملاحظة'));
        await tester.pumpAndSettle();

        expect(result, AyahAction.addNote);
      });

      testWidgets('tapping copy text returns correct result', (tester) async {
        AyahAction? result;
        await tester.pumpWidget(
          _AyahActionHarness(
            position: testPosition,
            onResult: (r) => result = r,
          ),
        );
        await tester.tap(find.byKey(const Key('show_menu')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('نسخ'));
        await tester.pumpAndSettle();

        expect(result, AyahAction.copyText);
      });

      testWidgets('tapping share text returns correct result', (tester) async {
        AyahAction? result;
        await tester.pumpWidget(
          _AyahActionHarness(
            position: testPosition,
            onResult: (r) => result = r,
          ),
        );
        await tester.tap(find.byKey(const Key('show_menu')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('مشاركة النص'));
        await tester.pumpAndSettle();

        expect(result, AyahAction.shareText);
      });

      testWidgets('tapping share image returns correct result', (tester) async {
        AyahAction? result;
        await tester.pumpWidget(
          _AyahActionHarness(
            position: testPosition,
            onResult: (r) => result = r,
          ),
        );
        await tester.tap(find.byKey(const Key('show_menu')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('مشاركة صورة'));
        await tester.pumpAndSettle();

        expect(result, AyahAction.shareImage);
      });
    });

    group('word actions', () {
      testWidgets('shows ayah words inside a mushaf scroller', (tester) async {
        await tester.pumpWidget(
          _AyahActionHarness(
            position: testPosition,
            selectedAyah: SelectedAyah(
              position: testPosition,
              text: 'بسم الله الرحمن الرحيم',
              reference: 'الفاتحة 1:1',
            ),
          ),
        );
        await tester.tap(find.byKey(const Key('show_menu')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('mushaf_word_scroller')), findsOneWidget);
        expect(find.text('بسم'), findsOneWidget);
        expect(find.text('الله'), findsOneWidget);
        expect(find.text('بسم الله الرحمن الرحيم'), findsNothing);
        expect(
          find.descendant(
            of: find.byKey(const Key('mushaf_word_scroller')),
            matching: find.byType(InkWell),
          ),
          findsNothing,
        );
      });

      testWidgets('plays selected word through word gateway', (tester) async {
        final gateway = FakeQuranGateway(positions: [testPosition]);
        await tester.pumpWidget(
          _AyahActionHarness(
            position: testPosition,
            selectedAyah: SelectedAyah(
              position: testPosition,
              text: 'نص آية اختباري',
              reference: 'الفاتحة 1:1',
            ),
            wordGateway: gateway,
          ),
        );
        await tester.tap(find.byKey(const Key('show_menu')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('mushaf_word_2')));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.volume_up_rounded));
        await tester.pumpAndSettle();

        expect(gateway.playedWords.single.wordNumber, 2);
      });

      testWidgets('selected word text turns blue', (tester) async {
        final gateway = FakeQuranGateway(positions: [testPosition]);
        await tester.pumpWidget(
          _AyahActionHarness(
            position: testPosition,
            selectedAyah: SelectedAyah(
              position: testPosition,
              text: 'نص آية اختباري',
              reference: 'الفاتحة 1:1',
            ),
            wordGateway: gateway,
          ),
        );
        await tester.tap(find.byKey(const Key('show_menu')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('mushaf_word_2')));
        await tester.pumpAndSettle();

        final selectedText = tester.widget<Text>(
          find.byKey(const Key('mushaf_word_text_2')),
        );
        expect(
          selectedText.style?.color,
          isSameColorAs(const Color(0xFF1E88D8)),
        );
      });

      testWidgets('loads selected word details inline through word gateway', (
        tester,
      ) async {
        final gateway = FakeQuranGateway(positions: [testPosition]);
        await tester.pumpWidget(
          _AyahActionHarness(
            position: testPosition,
            selectedAyah: SelectedAyah(
              position: testPosition,
              text: 'نص آية اختباري',
              reference: 'الفاتحة 1:1',
            ),
            wordGateway: gateway,
          ),
        );
        await tester.tap(find.byKey(const Key('show_menu')));
        await tester.pumpAndSettle();

        expect(find.text('بيانات القراءات'), findsOneWidget);

        await tester.tap(find.byKey(const Key('mushaf_word_3')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('التصريف'));
        await tester.pumpAndSettle();

        expect(find.text('بيانات التصريف'), findsOneWidget);
      });
    });

    group('close behavior', () {
      testWidgets('tapping close button dismisses the sheet', (tester) async {
        AyahAction? result;
        await tester.pumpWidget(
          _AyahActionHarness(
            position: testPosition,
            onResult: (r) => result = r,
          ),
        );
        await tester.tap(find.byKey(const Key('show_menu')));
        await tester.pumpAndSettle();

        expect(find.text('الفاتحة 1'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        expect(find.text('الفاتحة 1'), findsNothing);
        expect(result, isNull);
      });
    });
  });
}

class _AyahActionHarness extends StatelessWidget {
  const _AyahActionHarness({
    required this.position,
    this.onResult,
    this.selectedAyah,
    this.wordGateway,
  });

  final QuranPosition position;
  final void Function(AyahAction? result)? onResult;
  final SelectedAyah? selectedAyah;
  final QuranWordGateway? wordGateway;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: RaqeemTheme.light(),
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (innerContext) {
              return ElevatedButton(
                key: const Key('show_menu'),
                onPressed: () async {
                  final result = await AyahActionMenu.show(
                    innerContext,
                    position: position,
                    selectedAyah: selectedAyah,
                    wordGateway: wordGateway,
                  );
                  onResult?.call(result);
                },
                child: const Text('Show Menu'),
              );
            },
          ),
        ),
      ),
    );
  }
}
