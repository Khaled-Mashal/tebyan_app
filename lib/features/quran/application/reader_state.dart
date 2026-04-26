import 'package:flutter/foundation.dart';

import '../../../shared/errors/app_error.dart';
import '../domain/quran_position.dart';

enum ReaderStatus { loading, ready, error }

@immutable
class ReaderCommand {
  const ReaderCommand({this.position, this.destination});

  const ReaderCommand.showAyahActions(this.position) : destination = null;

  const ReaderCommand.navigate(this.destination) : position = null;

  final QuranPosition? position;
  final String? destination;

  @override
  bool operator ==(Object other) =>
      other is ReaderCommand &&
      other.position == position &&
      other.destination == destination;

  @override
  int get hashCode => Object.hash(position, destination);
}

@immutable
class ReaderState {
  const ReaderState({
    required this.status,
    this.position,
    this.selectedAyahPosition,
    this.areControlsVisible = true,
    this.error,
  });

  factory ReaderState.initial() =>
      const ReaderState(status: ReaderStatus.loading);

  final ReaderStatus status;
  final QuranPosition? position;
  final QuranPosition? selectedAyahPosition;
  final bool areControlsVisible;
  final AppError? error;

  bool get isAyahSelected => selectedAyahPosition != null;

  ReaderState copyWith({
    ReaderStatus? status,
    QuranPosition? position,
    QuranPosition? selectedAyahPosition,
    bool? areControlsVisible,
    AppError? error,
    bool clearError = false,
    bool clearSelection = false,
  }) {
    return ReaderState(
      status: status ?? this.status,
      position: position ?? this.position,
      selectedAyahPosition: clearSelection
          ? null
          : (selectedAyahPosition ?? this.selectedAyahPosition),
      areControlsVisible: areControlsVisible ?? this.areControlsVisible,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
