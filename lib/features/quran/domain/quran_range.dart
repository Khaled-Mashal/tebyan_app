import 'package:flutter/foundation.dart';

import 'quran_position.dart';

enum QuranRangeUnitHint { ayah, page, surah, wird, custom }

@immutable
class QuranRange {
  QuranRange({
    required this.start,
    required this.end,
    this.unitHint = QuranRangeUnitHint.custom,
  }) {
    if (start.page > end.page) {
      throw const QuranRangeException(
        'لا يمكن أن تكون بداية النطاق بعد نهايته.',
      );
    }
  }

  final QuranPosition start;
  final QuranPosition end;
  final QuranRangeUnitHint unitHint;

  int get pageCount => end.page - start.page + 1;

  bool containsPage(int page) {
    return page >= start.page && page <= end.page;
  }

  Map<String, Object?> toJson() {
    return {
      'start': start.toJson(),
      'end': end.toJson(),
      'unitHint': unitHint.name,
    };
  }

  factory QuranRange.fromJson(Map<String, Object?> json) {
    return QuranRange(
      start: QuranPosition.fromJson(
        Map<String, Object?>.from(json['start']! as Map),
      ),
      end: QuranPosition.fromJson(
        Map<String, Object?>.from(json['end']! as Map),
      ),
      unitHint: QuranRangeUnitHint.values.byName(
        json['unitHint'] as String? ?? QuranRangeUnitHint.custom.name,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is QuranRange &&
        other.start == start &&
        other.end == end &&
        other.unitHint == unitHint;
  }

  @override
  int get hashCode => Object.hash(start, end, unitHint);
}

class QuranRangeException implements FormatException {
  const QuranRangeException(this.message);

  @override
  final String message;

  @override
  int? get offset => null;

  @override
  Object? get source => null;

  @override
  String toString() => 'QuranRangeException: $message';
}
