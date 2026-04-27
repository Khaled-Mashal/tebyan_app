import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../shared/errors/result.dart';
import '../../home/domain/last_reading_entry.dart';
import '../../home/infrastructure/last_reading_repository.dart';
import '../../quran/domain/quran_position.dart';

class ReaderPositionService extends ChangeNotifier with WidgetsBindingObserver {
  ReaderPositionService({required LastReadingRepository repository})
    : _repository = repository;

  final LastReadingRepository _repository;
  QuranPosition? _currentPosition;
  bool _isDisposed = false;
  Timer? _debounceTimer;

  static const _debounceDuration = Duration(seconds: 1);

  QuranPosition? get currentPosition => _currentPosition;

  void attach() {
    WidgetsBinding.instance.addObserver(this);
  }

  void updatePosition(QuranPosition position) {
    if (_isDisposed) return;
    _currentPosition = position;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (!_isDisposed && _currentPosition != null) {
        saveCurrentPosition();
      }
    });
  }

  Future<Result<void>> saveCurrentPosition() async {
    final position = _currentPosition;
    if (position == null) return const Success<void>(null);

    final entry = LastReadingEntry(
      id: '${position.page}-${DateTime.now().microsecondsSinceEpoch}',
      position: position,
      source: LastReadingSource.reader,
      savedAt: DateTime.now().toUtc(),
      displayTitle: position.displaySurahName,
      displaySubtitle: position.displayAyahLabel,
    );

    return _repository.saveEntry(entry);
  }

  Future<Result<void>> saveAndClear() async {
    final result = await saveCurrentPosition();
    _currentPosition = null;
    return result;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _debounceTimer?.cancel();
      saveCurrentPosition();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _isDisposed = true;
    _flushPositionToRepository();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _flushPositionToRepository() {
    final position = _currentPosition;
    if (position == null) return;
    final entry = LastReadingEntry(
      id: '${position.page}-${DateTime.now().microsecondsSinceEpoch}',
      position: position,
      source: LastReadingSource.reader,
      savedAt: DateTime.now().toUtc(),
      displayTitle: position.displaySurahName,
      displaySubtitle: position.displayAyahLabel,
    );
    _repository.saveEntry(entry);
  }
}
