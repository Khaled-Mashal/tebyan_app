import 'package:flutter/foundation.dart';

import '../../../shared/errors/app_error.dart';
import '../../../shared/errors/result.dart';
import '../domain/bookmark_annotation.dart';
import '../infrastructure/bookmark_repository.dart';

enum BookmarksStatus { loading, ready, error }

class BookmarksViewModel extends ChangeNotifier {
  BookmarksViewModel({required BookmarkRepository repository})
    : _repository = repository;

  final BookmarkRepository _repository;

  List<BookmarkAnnotation> _bookmarks = [];
  BookmarksStatus _status = BookmarksStatus.loading;
  AppError? _error;

  List<BookmarkAnnotation> get bookmarks => List.unmodifiable(_bookmarks);
  BookmarksStatus get status => _status;
  AppError? get error => _error;
  bool get isEmpty => _bookmarks.isEmpty && _status == BookmarksStatus.ready;

  Future<void> loadBookmarks() async {
    _status = BookmarksStatus.loading;
    _error = null;
    notifyListeners();

    final result = await _repository.list();
    switch (result) {
      case Success<List<BookmarkAnnotation>>(:final value):
        _bookmarks = value;
        _status = BookmarksStatus.ready;
      case Failure<List<BookmarkAnnotation>>(:final error):
        _error = error;
        _status = BookmarksStatus.error;
    }
    notifyListeners();
  }

  Future<void> deleteBookmark(String id) async {
    final result = await _repository.delete(id);
    switch (result) {
      case Success():
        _bookmarks = _bookmarks.where((b) => b.id != id).toList();
        notifyListeners();
      case Failure(:final error):
        _error = error;
        notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
