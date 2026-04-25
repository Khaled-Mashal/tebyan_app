import 'package:flutter/foundation.dart';

import '../../quran/domain/quran_range.dart';
import '../../../shared/errors/result.dart';

@immutable
class ActiveKhatmaSummary {
  const ActiveKhatmaSummary({
    required this.planId,
    required this.planName,
    required this.todayWirdTitle,
    required this.completedAssignedPages,
    required this.totalAssignedPages,
    this.todayRange,
  });

  final String planId;
  final String planName;
  final String todayWirdTitle;
  final int completedAssignedPages;
  final int totalAssignedPages;
  final QuranRange? todayRange;

  double get progress {
    if (totalAssignedPages <= 0) {
      return 0;
    }
    return (completedAssignedPages / totalAssignedPages).clamp(0, 1);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveKhatmaSummary &&
        other.planId == planId &&
        other.planName == planName &&
        other.todayWirdTitle == todayWirdTitle &&
        other.completedAssignedPages == completedAssignedPages &&
        other.totalAssignedPages == totalAssignedPages &&
        other.todayRange == todayRange;
  }

  @override
  int get hashCode => Object.hash(
    planId,
    planName,
    todayWirdTitle,
    completedAssignedPages,
    totalAssignedPages,
    todayRange,
  );
}

abstract interface class ActiveKhatmaReader {
  Future<Result<ActiveKhatmaSummary?>> loadActiveSummary(DateTime date);
}

class NoopActiveKhatmaReader implements ActiveKhatmaReader {
  const NoopActiveKhatmaReader();

  @override
  Future<Result<ActiveKhatmaSummary?>> loadActiveSummary(DateTime date) async {
    return const Success<ActiveKhatmaSummary?>(null);
  }
}
