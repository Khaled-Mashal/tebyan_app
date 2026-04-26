import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tebyan_app/app/localization/app_localizations.dart';
import 'package:tebyan_app/app/theme/raqeem_theme.dart';
import 'package:tebyan_app/features/quran/domain/quran_position.dart';
import 'package:tebyan_app/features/quran/infrastructure/quran_gateway.dart';
import 'package:tebyan_app/features/quran/presentation/explanation_sheet.dart';

import '../../../shared/fakes/fake_quran_gateway.dart';

void main() {
  testWidgets('tafsir sheet shows selected ayah in mushaf layout', (
    tester,
  ) async {
    final position = QuranPosition(
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

    await tester.pumpWidget(
      _ExplanationHarness(
        position: position,
        selectedAyah: SelectedAyah(
          position: position,
          text: 'بسم الله الرحمن الرحيم',
          reference: 'الفاتحة 1:1',
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('show_tafsir')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('explanation_mushaf_ayah')), findsOneWidget);
    expect(find.text('بسم'), findsOneWidget);
    expect(find.text('الله'), findsOneWidget);
    expect(find.text('نص تفسير اختباري'), findsOneWidget);
  });
}

class _ExplanationHarness extends StatelessWidget {
  const _ExplanationHarness({
    required this.position,
    required this.selectedAyah,
  });

  final QuranPosition position;
  final SelectedAyah selectedAyah;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: RaqeemTheme.light(),
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: Builder(
          builder: (innerContext) {
            return Center(
              child: ElevatedButton(
                key: const Key('show_tafsir'),
                onPressed: () {
                  ExplanationSheet.showTafsir(
                    innerContext,
                    position: position,
                    explanationGateway: FakeQuranGateway(positions: [position]),
                    selectedAyah: selectedAyah,
                  );
                },
                child: const Text('Show Tafsir'),
              ),
            );
          },
        ),
      ),
    );
  }
}
