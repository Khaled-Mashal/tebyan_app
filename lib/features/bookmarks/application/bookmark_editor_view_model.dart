import 'package:flutter/foundation.dart';

import '../../../shared/errors/app_error.dart';
import '../../../shared/errors/result.dart';
import '../../quran/domain/quran_position.dart';
import '../domain/bookmark_annotation.dart';
import '../infrastructure/bookmark_repository.dart';

enum BookmarkEditorStatus { idle, saving, saved, error }

class BookmarkEditorViewModel extends ChangeNotifier {
  BookmarkEditorViewModel({
    required BookmarkRepository repository,
    BookmarkAnnotation? existing,
  }) : _repository = repository,
       _existing = existing;

  final BookmarkRepository _repository;
  final BookmarkAnnotation? _existing;

  BookmarkEditorStatus _status = BookmarkEditorStatus.idle;
  AppError? _error;
  BookmarkType _type = BookmarkType.bookmark;
  BookmarkColor _color = BookmarkColor.gold;
  String? _note;

  BookmarkEditorStatus get status => _status;
  AppError? get error => _error;
  BookmarkType get type => _type;
  BookmarkColor get color => _color;
  String? get note => _note;
  bool get isEditing => _existing != null;

  void setType(BookmarkType type) {
    _type = type;
    notifyListeners();
  }

  void setColor(BookmarkColor color) {
    _color = color;
    notifyListeners();
  }

  void setNote(String? note) {
    _note = note;
    notifyListeners();
  }

  Future<Result<BookmarkAnnotation>> save({
    required QuranPosition position,
    int? quranLibraryBookmarkId,
  }) async {
    _status = BookmarkEditorStatus.saving;
    _error = null;
    notifyListeners();

    final now = DateTime.now().toUtc();
    final annotation = BookmarkAnnotation(
      id: _existing?.id ?? 'bm-${now.millisecondsSinceEpoch}',
      position: position,
      quranLibraryBookmarkId:
          quranLibraryBookmarkId ?? _existing?.quranLibraryBookmarkId,
      type: _type,
      note: _note,
      color: _color,
      createdAt: _existing?.createdAt ?? now,
      updatedAt: now,
    );

    final Result<BookmarkAnnotation> result;
    if (_existing != null) {
      result = await _repository.update(annotation);
    } else {
      result = await _repository.create(annotation);
    }

    switch (result) {
      case Success<BookmarkAnnotation>():
        _status = BookmarkEditorStatus.saved;
      case Failure<BookmarkAnnotation>(:final error):
        _status = BookmarkEditorStatus.error;
        _error = error;
    }
    notifyListeners();
    return result;
  }
}
