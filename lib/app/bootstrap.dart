import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import '../features/bookmarks/infrastructure/bookmark_repository.dart';
import '../features/home/infrastructure/last_reading_repository.dart';
import '../features/khatma/application/active_khatma_summary.dart';
import '../features/quran/infrastructure/quran_gateway.dart';
import '../features/quran/infrastructure/quran_library_gateway.dart';
import '../features/settings/infrastructure/preferences_repository.dart';
import '../shared/persistence/raqeem_database.dart';
import '../shared/platform/local_notification_scheduler.dart';
import '../shared/platform/share_gateway.dart';

class RaqeemBootstrapConfig {
  const RaqeemBootstrapConfig({
    this.languageCode = 'ar',
    this.enableWordAudio = false,
  });

  final String languageCode;
  final bool enableWordAudio;
}

Future<void> bootstrapRaqeemApp({
  RaqeemBootstrapConfig config = const RaqeemBootstrapConfig(),
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final raqeemDatabase = RaqeemDatabase();
  final quranGateway = QuranLibraryGateway();
  final notificationScheduler = FlutterLocalNotificationScheduler();
  final shareGateway = SharePlusGateway();

  final db = await raqeemDatabase.open();
  await quranGateway.initialize(
    languageCode: config.languageCode,
    enableWordAudio: config.enableWordAudio,
  );

  final preferencesRepository = SqlitePreferencesRepository(db);
  final lastReadingRepository = SqliteLastReadingRepository(db);
  final bookmarkRepository = SqliteBookmarkRepository(db);
  const activeKhatmaReader = NoopActiveKhatmaReader();

  runApp(
    MultiProvider(
      providers: [
        Provider<RaqeemDatabase>.value(value: raqeemDatabase),
        Provider<QuranGateway>.value(value: quranGateway),
        Provider<QuranNavigationGateway>.value(value: quranGateway),
        Provider<QuranSelectionGateway>.value(value: quranGateway),
        Provider<QuranExplanationGateway>.value(value: quranGateway),
        Provider<QuranBookmarkGateway>.value(value: quranGateway),
        Provider<QuranSearchGateway>.value(value: quranGateway),
        Provider<QuranAudioGateway>.value(value: quranGateway),
        Provider<QuranWordGateway>.value(value: quranGateway),
        Provider<PreferencesRepository>.value(value: preferencesRepository),
        Provider<BookmarkRepository>.value(value: bookmarkRepository),
        Provider<LastReadingRepository>.value(value: lastReadingRepository),
        Provider<ActiveKhatmaReader>.value(value: activeKhatmaReader),
        Provider<LocalNotificationScheduler>.value(
          value: notificationScheduler,
        ),
        Provider<ShareGateway>.value(value: shareGateway),
      ],
      child: const RaqeemApp(),
    ),
  );
}
