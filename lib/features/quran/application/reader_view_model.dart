import 'package:flutter/foundation.dart';

import '../../../shared/errors/app_error.dart';
import '../../../shared/errors/result.dart';
import '../domain/quran_position.dart';
import '../infrastructure/quran_gateway.dart';
import 'reader_position_service.dart';
import 'reader_state.dart';

class ReaderViewModel extends ChangeNotifier {
  ReaderViewModel({
    required QuranNavigationGateway navigationGateway,
    ReaderPositionService? positionService,
    void Function(ReaderCommand command)? onCommand,
  }) : _navigationGateway = navigationGateway,
       _positionService = positionService,
       _onCommand = onCommand;

  final QuranNavigationGateway _navigationGateway;
  final ReaderPositionService? _positionService;
  // ignore: unused_field
  final void Function(ReaderCommand command)? _onCommand;

  ReaderState _state = ReaderState.initial();

  ReaderState get state => _state;

  Future<void> openAtPosition(QuranPosition position) async {
    _setState(
      _state.copyWith(
        status: ReaderStatus.ready,
        position: position,
        clearError: true,
      ),
    );
  }

  Future<void> openAtPage(int page) async {
    try {
      final position = await _navigationGateway.resolvePageStart(page);
      await openAtPosition(position);
    } catch (e, st) {
      _handleError(e, st);
    }
  }

  Future<void> navigateBySurah(int surahNumber) async {
    try {
      final position = await _navigationGateway.resolveSurahStart(surahNumber);
      _navigationGateway.jumpToPosition(position);
      _setState(
        _state.copyWith(
          status: ReaderStatus.ready,
          position: position,
          clearError: true,
        ),
      );
    } catch (e, st) {
      _handleError(e, st);
    }
  }

  Future<void> navigateByJuz(int juzNumber) async {
    try {
      final position = await _navigationGateway.resolveJuzStart(juzNumber);
      _navigationGateway.jumpToPosition(position);
      _setState(
        _state.copyWith(
          status: ReaderStatus.ready,
          position: position,
          clearError: true,
        ),
      );
    } catch (e, st) {
      _handleError(e, st);
    }
  }

  Future<void> navigateByHizb(int hizbNumber) async {
    try {
      final position = await _navigationGateway.resolveHizbStart(hizbNumber);
      _navigationGateway.jumpToPosition(position);
      _setState(
        _state.copyWith(
          status: ReaderStatus.ready,
          position: position,
          clearError: true,
        ),
      );
    } catch (e, st) {
      _handleError(e, st);
    }
  }

  Future<void> navigateByRub(int rubNumber) async {
    try {
      final position = await _navigationGateway.resolveRubStart(rubNumber);
      _navigationGateway.jumpToPosition(position);
      _setState(
        _state.copyWith(
          status: ReaderStatus.ready,
          position: position,
          clearError: true,
        ),
      );
    } catch (e, st) {
      _handleError(e, st);
    }
  }

  void toggleControls() {
    _setState(_state.copyWith(areControlsVisible: !_state.areControlsVisible));
  }

  void selectAyah(QuranPosition position) {
    _setState(_state.copyWith(selectedAyahPosition: position));
  }

  void clearAyahSelection() {
    _setState(_state.copyWith(clearSelection: true));
  }

  Future<Result<void>> saveLastPosition() async {
    final position = _state.position;
    if (position == null) return const Success<void>(null);
    final service = _positionService;
    if (service == null) return const Success<void>(null);
    service.updatePosition(position);
    return service.saveCurrentPosition();
  }

  void _handleError(Object error, StackTrace stackTrace) {
    _setState(
      _state.copyWith(
        status: ReaderStatus.error,
        error: error is AppError
            ? error
            : AppError.fromException(error, stackTrace),
      ),
    );
  }

  void _setState(ReaderState state) {
    _state = state;
    notifyListeners();
  }
}
