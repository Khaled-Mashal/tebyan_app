import 'package:flutter/foundation.dart';

import '../../quran/domain/quran_position.dart';

enum BookmarkType { bookmark, note, reflection, memorization, custom }

enum BookmarkColor { gold, green, red, blue, neutral }

@immutable
class BookmarkAnnotation {
  const BookmarkAnnotation({
    required this.id,
    required this.position,
    this.quranLibraryBookmarkId,
    this.type = BookmarkType.bookmark,
    this.note,
    this.color = BookmarkColor.gold,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastOpenedAt,
  });

  final String id;
  final int? quranLibraryBookmarkId;
  final QuranPosition position;
  final BookmarkType type;
  final String? note;
  final BookmarkColor color;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastOpenedAt;

  BookmarkAnnotation copyWith({
    int? quranLibraryBookmarkId,
    BookmarkType? type,
    String? note,
    BookmarkColor? color,
    bool? isArchived,
    DateTime? updatedAt,
    DateTime? lastOpenedAt,
  }) {
    return BookmarkAnnotation(
      id: id,
      position: position,
      quranLibraryBookmarkId:
          quranLibraryBookmarkId ?? this.quranLibraryBookmarkId,
      type: type ?? this.type,
      note: note ?? this.note,
      color: color ?? this.color,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BookmarkAnnotation && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
