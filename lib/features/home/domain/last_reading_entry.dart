import 'package:flutter/foundation.dart';

import '../../quran/domain/quran_position.dart';

enum LastReadingSource { reader, bookmark, search, khatma, audio }

@immutable
class LastReadingEntry {
  const LastReadingEntry({
    required this.id,
    required this.position,
    required this.source,
    required this.savedAt,
    required this.displayTitle,
    required this.displaySubtitle,
  });

  final String id;
  final QuranPosition position;
  final LastReadingSource source;
  final DateTime savedAt;
  final String displayTitle;
  final String displaySubtitle;

  @override
  bool operator ==(Object other) {
    return other is LastReadingEntry &&
        other.id == id &&
        other.position == position &&
        other.source == source &&
        other.savedAt == savedAt &&
        other.displayTitle == displayTitle &&
        other.displaySubtitle == displaySubtitle;
  }

  @override
  int get hashCode =>
      Object.hash(id, position, source, savedAt, displayTitle, displaySubtitle);
}
