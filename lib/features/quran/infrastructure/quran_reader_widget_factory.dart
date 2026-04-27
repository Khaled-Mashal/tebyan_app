import 'package:flutter/widgets.dart';
import 'package:quran_library/quran_library.dart';

import '../domain/quran_range.dart';
import '../presentation/raqeem_reader_style.dart';

abstract interface class QuranReaderWidgetFactory {
  Widget buildFullReader({
    required BuildContext context,
    required RaqeemReaderStyle style,
    required String languageCode,
    required int initialPageIndex,
    required ValueChanged<int> onPageChanged,
    required void Function(int ayahUQNumber) onAyahSelected,
    VoidCallback? onPageTap,
  });

  Widget buildPageRange({
    required BuildContext context,
    required QuranRange range,
    required List<int> highlightedAyahUQNumbers,
    required RaqeemReaderStyle style,
    required String languageCode,
  });
}

class QuranLibraryReaderWidgetFactory implements QuranReaderWidgetFactory {
  QuranLibraryReaderWidgetFactory();

  @override
  Widget buildFullReader({
    required BuildContext context,
    required RaqeemReaderStyle style,
    required String languageCode,
    required int initialPageIndex,
    required ValueChanged<int> onPageChanged,
    required void Function(int ayahUQNumber) onAyahSelected,
    VoidCallback? onPageTap,
  }) {
    return _PageJumpScope(
      initialPageIndex: initialPageIndex,
      child: QuranLibraryScreen(
        parentContext: context,
        isDark: style.isDark,
        backgroundColor: style.backgroundColor,
        textColor: style.textColor,
        ayahSelectedBackgroundColor: style.accentColor.withValues(alpha: 0.2),
        ayahSelectedFontColor: style.textColor,
        appLanguageCode: languageCode,
        pageIndex: initialPageIndex,
        useDefaultAppBar: false,
        withPageView: true,
        showAyahBookmarkedIcon: false,
        isShowAudioSlider: false,
        isShowTabBar: false,
        isShowDisplayModeBar: false,
        enableWordSelection: false,
        wordInfoBottomSheetStyle: style.wordInfoBottomSheetStyle,
        topBarStyle: style.topBarStyle,
        topBottomQuranStyle: style.topBottomStyle,
        bannerStyle: style.bannerStyle,
        basmalaStyle: style.basmalaStyle,
        surahNameStyle: style.surahNameStyle,
        surahInfoStyle: style.surahInfoStyle,
        ayahMenuStyle: style.ayahMenuStyle,
        snackBarStyle: style.snackBarStyle,
        downloadFontsDialogStyle: style.downloadFontsDialogStyle,
        onPageChanged: (int pageNumber) {
          onPageChanged(pageNumber);
        },
        onPagePress: onPageTap,
        onAyahLongPress: (details, ayah) {
          onAyahSelected(ayah.ayahUQNumber);
        },
      ),
    );
  }

  @override
  Widget buildPageRange({
    required BuildContext context,
    required QuranRange range,
    required List<int> highlightedAyahUQNumbers,
    required RaqeemReaderStyle style,
    required String languageCode,
  }) {
    return QuranPagesScreen(
      parentContext: context,
      isDark: style.isDark,
      backgroundColor: style.backgroundColor,
      textColor: style.textColor,
      ayahSelectedBackgroundColor: style.accentColor.withValues(alpha: 0.2),
      ayahSelectedFontColor: style.textColor,
      appLanguageCode: languageCode,
      startPage: range.start.page,
      endPage: range.end.page,
      useDefaultAppBar: false,
      withPageView: true,
      showAyahBookmarkedIcon: false,
      isShowAudioSlider: false,
      highlightedAyahs: highlightedAyahUQNumbers,
      topBottomQuranStyle: style.topBottomStyle,
      bannerStyle: style.bannerStyle,
      basmalaStyle: style.basmalaStyle,
      surahNameStyle: style.surahNameStyle,
      surahInfoStyle: style.surahInfoStyle,
      ayahMenuStyle: style.ayahMenuStyle,
      snackBarStyle: style.snackBarStyle,
    );
  }
}

class _PageJumpScope extends StatefulWidget {
  const _PageJumpScope({required this.initialPageIndex, required this.child});

  final int initialPageIndex;
  final Widget child;

  @override
  State<_PageJumpScope> createState() => _PageJumpScopeState();
}

class _PageJumpScopeState extends State<_PageJumpScope> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = QuranCtrl.instance.quranPagesController;
      if (controller.hasClients) {
        controller.jumpToPage(widget.initialPageIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
