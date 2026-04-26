import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';

import '../../../app/theme/raqeem_theme.dart';

class RaqeemReaderStyle {
  const RaqeemReaderStyle({required this.isDark, required this.languageCode});

  final bool isDark;
  final String languageCode;

  Color get backgroundColor =>
      isDark ? RaqeemColors.nightBackground : RaqeemColors.background;

  Color get textColor =>
      isDark ? RaqeemColors.nightText : RaqeemColors.primaryText;

  Color get secondaryTextColor =>
      isDark ? RaqeemColors.nightSecondaryText : RaqeemColors.secondaryText;

  Color get accentColor => RaqeemColors.accentGold;

  Color get surfaceColor =>
      isDark ? RaqeemColors.nightSurface : RaqeemColors.surface;

  QuranTopBarStyle get topBarStyle => QuranTopBarStyle(
    showBackButton: false,
    showMenuButton: false,
    showAudioButton: false,
    showFontsButton: false,
    showTajweedButton: false,
    showAutoScrollButton: false,
    backgroundColor: backgroundColor,
    textColor: textColor,
    accentColor: accentColor,
    iconColor: textColor,
    height: 0,
    elevation: 0,
    padding: EdgeInsets.zero,
  );

  TopBottomQuranStyle get topBottomStyle => TopBottomQuranStyle(
    surahNameColor: secondaryTextColor,
    juzTextColor: secondaryTextColor,
    hizbTextColor: secondaryTextColor,
    pageNumberColor: secondaryTextColor,
    sajdaNameColor: RaqeemColors.warning,
    juzName: languageCode == 'ar' ? 'الجزء' : 'Juz',
    hizbName: languageCode == 'ar' ? 'الحزب' : 'Hizb',
    sajdaName: languageCode == 'ar' ? 'سجدة' : 'Sajdah',
    surahName: languageCode == 'ar' ? 'سورة' : 'Surah',
  );

  BannerStyle get bannerStyle => BannerStyle(svgBannerColor: accentColor);

  BasmalaStyle get basmalaStyle => BasmalaStyle(basmalaColor: textColor);

  SurahNameStyle get surahNameStyle =>
      SurahNameStyle(surahNameColor: textColor);

  SurahInfoStyle get surahInfoStyle => SurahInfoStyle(
    backgroundColor: surfaceColor,
    closeIconColor: textColor,
    surahNameColor: RaqeemColors.primary,
    surahNumberColor: textColor,
    primaryColor: RaqeemColors.primary,
    titleColor: textColor,
    indicatorColor: accentColor,
    textColor: secondaryTextColor,
    surahNumberDecorationColor: accentColor,
    firstTabText: languageCode == 'ar' ? 'معلومات السورة' : 'Surah Info',
    secondTabText: languageCode == 'ar' ? 'الآيات' : 'Ayahs',
  );

  AyahMenuStyle get ayahMenuStyle => AyahMenuStyle(
    backgroundColor: surfaceColor,
    borderColor: accentColor.withValues(alpha: 0.3),
    borderRadius: 12,
    copyIconColor: textColor,
    tafsirIconColor: RaqeemColors.primary,
    playIconColor: RaqeemColors.primary,
    playAllIconColor: RaqeemColors.primary,
    dividerColor: secondaryTextColor.withValues(alpha: 0.15),
    showBookmarkButtons: true,
    showCopyButton: true,
    showTafsirButton: true,
    showPlayButton: true,
    showPlayAllButton: true,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.12),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    iconSize: 20,
    copySuccessMessage: languageCode == 'ar' ? 'تم نسخ الآية' : 'Ayah copied',
  );

  SnackBarStyle get snackBarStyle => SnackBarStyle(
    backgroundColor: surfaceColor,
    textStyle: TextStyle(color: textColor, fontSize: 14),
    behavior: SnackBarBehavior.floating,
    borderRadius: 8,
    actionTextColor: RaqeemColors.primary,
  );

  DownloadFontsDialogStyle get downloadFontsDialogStyle =>
      DownloadFontsDialogStyle(
        backgroundColor: surfaceColor,
        titleColor: textColor,
        notesColor: secondaryTextColor,
        downloadButtonBackgroundColor: RaqeemColors.primary,
        iconColor: RaqeemColors.primary,
        dividerColor: secondaryTextColor.withValues(alpha: 0.15),
        headerTitle: languageCode == 'ar' ? 'تحميل الخطوط' : 'Download Fonts',
        notes: languageCode == 'ar'
            ? 'مطلوب لعرض المصحف بالخطوط الجميلة'
            : 'Required for beautiful mushaf font display',
      );

  WordInfoBottomSheetStyle get wordInfoBottomSheetStyle =>
      WordInfoBottomSheetStyle(
        backgroundColor: RaqeemColors.softWhite,
        borderRadius: 16,
        padding: const EdgeInsets.only(bottom: 16),
        maxHeightFactor: 0.85,
        handleWidth: 48,
        handleHeight: 4,
        handleBorderRadius: 2,
        handleColor: RaqeemColors.secondaryText.withValues(alpha: 0.25),
        withTitle: true,
        titleText: languageCode == 'ar' ? 'عن الكلمة' : 'Word Info',
        titleTextStyle: TextStyle(
          color: RaqeemColors.primaryText,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        tabRecitationsText: 'القراءات',
        tabTasreefText: 'التصريف',
        tabEerabText: 'الإعراب',
        tabLabelStyle: TextStyle(
          color: RaqeemColors.primaryText,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        tabLabelColor: RaqeemColors.primaryText,
        tabUnselectedLabelColor: RaqeemColors.secondaryText,
        tabIndicatorColor: RaqeemColors.primary,
        tabBackgroundColor: RaqeemColors.surface,
        tabIndicatorRadius: 10,
        tabBarHeight: 44,
        dividerHeight: 1,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        bodyTextStyle: TextStyle(
          color: RaqeemColors.primaryText,
          fontSize: 15,
          height: 1.8,
        ),
        buttonTextStyle: TextStyle(
          color: RaqeemColors.softWhite,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        progressTextStyle: TextStyle(
          color: RaqeemColors.secondaryText,
          fontSize: 12,
        ),
        verticalMargin: 8,
        horizontalMargin: 8,
        innerContainerPadding: const EdgeInsets.all(16),
        textBackgroundColor: isDark
            ? RaqeemColors.nightSurface
            : RaqeemColors.surface,
        tafsirBackgroundColor: isDark
            ? RaqeemColors.nightBackground
            : RaqeemColors.background,
        innerContainerBorderRadius: RaqeemRadii.medium,
        innerBorderColor: RaqeemColors.secondaryText.withValues(alpha: 0.12),
        innerBorderWidth: 1,
        innerShadowColor: Colors.black.withValues(alpha: 0.06),
        innerShadowBlurRadius: 8,
        innerShadowOffset: const Offset(0, 2),
        audioButtonColor: RaqeemColors.primary,
        audioButtonActiveColor: RaqeemColors.primary.withValues(alpha: 0.8),
        audioButtonSize: 22,
        playWordTooltip: 'تشغيل الكلمة',
        playAyahWordsTooltip: 'تشغيل كلمات الآية',
        withWordAudioButton: true,
        withWordText: true,
        unavailableDataTemplate: 'بيانات {kind} غير محمّلة على الجهاز.',
        downloadText: 'تحميل',
        downloadingText: 'جاري التحميل...',
        loadErrorText: 'تعذر تحميل البيانات.',
        noDataText: 'لا توجد بيانات متاحة.',
      );
}
