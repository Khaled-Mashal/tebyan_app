import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const defaultLocale = Locale('ar');
  static const supportedLocales = <Locale>[Locale('ar'), Locale('en')];
  static const delegate = AppLocalizationsDelegate();
  static const localizationsDelegates = <LocalizationsDelegate<Object>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static Locale resolveLocale(
    Locale? deviceLocale,
    Iterable<Locale> supportedLocales,
  ) {
    if (deviceLocale == null) {
      return defaultLocale;
    }
    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == deviceLocale.languageCode,
      orElse: () => defaultLocale,
    );
  }

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    return localizations ?? const AppLocalizations(defaultLocale);
  }

  bool get isArabic => locale.languageCode == 'ar';
  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  String get appName => _lookup('appName');
  String get onboarding => _lookup('onboarding');
  String get home => _lookup('home');
  String get reader => _lookup('reader');
  String get bookmarks => _lookup('bookmarks');
  String get audio => _lookup('audio');
  String get khatma => _lookup('khatma');
  String get search => _lookup('search');
  String get settings => _lookup('settings');
  String get sharing => _lookup('sharing');
  String get foundationReady => _lookup('foundationReady');
  String get homeGreeting => _lookup('homeGreeting');
  String get homeGreetingBody => _lookup('homeGreetingBody');
  String get continueReading => _lookup('continueReading');
  String get resumeReading => _lookup('resumeReading');
  String get pageLabel => _lookup('pageLabel');
  String get ayahLabel => _lookup('ayahLabel');
  String get todayWird => _lookup('todayWird');
  String get shortcuts => _lookup('shortcuts');
  String get emptyReadingTitle => _lookup('emptyReadingTitle');
  String get emptyReadingBody => _lookup('emptyReadingBody');
  String get openReader => _lookup('openReader');
  String get retry => _lookup('retry');
  String get homeLoadError => _lookup('homeLoadError');

  String _lookup(String key) {
    final language = _strings[locale.languageCode] ?? _strings['en']!;
    return language[key] ?? _strings['en']![key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

const _strings = <String, Map<String, String>>{
  'en': {
    'appName': 'Raqeem',
    'onboarding': 'Onboarding',
    'home': 'Home',
    'reader': 'Reader',
    'bookmarks': 'Bookmarks',
    'audio': 'Audio',
    'khatma': 'Khatma',
    'search': 'Search',
    'settings': 'Settings',
    'sharing': 'Sharing',
    'foundationReady': 'Foundation route ready',
    'homeGreeting': 'Peace be upon you',
    'homeGreetingBody': 'Continue your Quran journey',
    'continueReading': 'Continue Reading',
    'resumeReading': 'Resume',
    'pageLabel': 'Page',
    'ayahLabel': 'Ayah',
    'todayWird': "Today's Wird",
    'shortcuts': 'Quick Access',
    'emptyReadingTitle': 'Start Your Quran Journey',
    'emptyReadingBody':
        'Open the reader and begin exploring the Holy Quran with Raqeem.',
    'openReader': 'Open Reader',
    'retry': 'Retry',
    'homeLoadError':
        'Unable to load dashboard. Please check your data and try again.',
  },
  'ar': {
    'appName': 'رقيم',
    'onboarding': 'التهيئة',
    'home': 'الرئيسية',
    'reader': 'القارئ',
    'bookmarks': 'العلامات',
    'audio': 'الصوت',
    'khatma': 'الختمة',
    'search': 'البحث',
    'settings': 'الإعدادات',
    'sharing': 'المشاركة',
    'foundationReady': 'مسار الأساس جاهز',
    'homeGreeting': 'السلام عليكم ورحمة الله',
    'homeGreetingBody': 'أكمل رحلتك مع القرآن الكريم',
    'continueReading': 'متابعة القراءة',
    'resumeReading': 'استمرار',
    'pageLabel': 'صفحة',
    'ayahLabel': 'آية',
    'todayWird': 'ورد اليوم',
    'shortcuts': 'الوصول السريع',
    'emptyReadingTitle': 'ابدأ رحلتك مع القرآن الكريم',
    'emptyReadingBody': 'افتح القارئ وابدأ بتصفح القرآن الكريم مع رقيم.',
    'openReader': 'فتح القارئ',
    'retry': 'إعادة المحاولة',
    'homeLoadError':
        'تعذر تحميل لوحة المعلومات. يرجى التحقق من البيانات والمحاولة مرة أخرى.',
  },
};
