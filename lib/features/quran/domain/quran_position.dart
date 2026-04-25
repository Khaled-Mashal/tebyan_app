import 'package:flutter/foundation.dart';

@immutable
class QuranPosition {
  QuranPosition({
    required this.surahNumber,
    required this.ayahNumber,
    required this.page,
    this.ayahUniqueNumber,
    this.juz,
    this.hizb,
    this.rub,
    this.displaySurahName = '',
    this.displayAyahLabel = '',
  }) {
    QuranPositionValidation.validate(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      page: page,
      juz: juz,
      hizb: hizb,
      rub: rub,
    );
  }

  final int surahNumber;
  final int ayahNumber;
  final int? ayahUniqueNumber;
  final int page;
  final int? juz;
  final int? hizb;
  final int? rub;
  final String displaySurahName;
  final String displayAyahLabel;

  QuranPosition copyWith({
    int? surahNumber,
    int? ayahNumber,
    int? ayahUniqueNumber,
    int? page,
    int? juz,
    int? hizb,
    int? rub,
    String? displaySurahName,
    String? displayAyahLabel,
  }) {
    return QuranPosition(
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      ayahUniqueNumber: ayahUniqueNumber ?? this.ayahUniqueNumber,
      page: page ?? this.page,
      juz: juz ?? this.juz,
      hizb: hizb ?? this.hizb,
      rub: rub ?? this.rub,
      displaySurahName: displaySurahName ?? this.displaySurahName,
      displayAyahLabel: displayAyahLabel ?? this.displayAyahLabel,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'ayahUniqueNumber': ayahUniqueNumber,
      'page': page,
      'juz': juz,
      'hizb': hizb,
      'rub': rub,
      'displaySurahName': displaySurahName,
      'displayAyahLabel': displayAyahLabel,
    };
  }

  factory QuranPosition.fromJson(Map<String, Object?> json) {
    return QuranPosition(
      surahNumber: json['surahNumber'] as int,
      ayahNumber: json['ayahNumber'] as int,
      ayahUniqueNumber: json['ayahUniqueNumber'] as int?,
      page: json['page'] as int,
      juz: json['juz'] as int?,
      hizb: json['hizb'] as int?,
      rub: json['rub'] as int?,
      displaySurahName: json['displaySurahName'] as String? ?? '',
      displayAyahLabel: json['displayAyahLabel'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    return other is QuranPosition &&
        other.surahNumber == surahNumber &&
        other.ayahNumber == ayahNumber &&
        other.ayahUniqueNumber == ayahUniqueNumber &&
        other.page == page &&
        other.juz == juz &&
        other.hizb == hizb &&
        other.rub == rub &&
        other.displaySurahName == displaySurahName &&
        other.displayAyahLabel == displayAyahLabel;
  }

  @override
  int get hashCode => Object.hash(
    surahNumber,
    ayahNumber,
    ayahUniqueNumber,
    page,
    juz,
    hizb,
    rub,
    displaySurahName,
    displayAyahLabel,
  );
}

class QuranPositionValidation {
  const QuranPositionValidation._();

  static const minSurah = 1;
  static const maxSurah = 114;
  static const minPage = 1;
  static const maxPage = 604;
  static const minJuz = 1;
  static const maxJuz = 30;
  static const minHizb = 1;
  static const maxHizb = 60;
  static const minRub = 1;
  static const maxRub = 240;

  static void validate({
    required int surahNumber,
    required int ayahNumber,
    required int page,
    int? juz,
    int? hizb,
    int? rub,
  }) {
    _checkRange('surahNumber', surahNumber, minSurah, maxSurah);
    _checkMin('ayahNumber', ayahNumber, 1);
    _checkRange('page', page, minPage, maxPage);
    if (juz != null) {
      _checkRange('juz', juz, minJuz, maxJuz);
    }
    if (hizb != null) {
      _checkRange('hizb', hizb, minHizb, maxHizb);
    }
    if (rub != null) {
      _checkRange('rub', rub, minRub, maxRub);
    }
  }

  static void _checkMin(String name, int value, int min) {
    if (value < min) {
      throw QuranPositionException('قيمة $name يجب ألا تقل عن $min.');
    }
  }

  static void _checkRange(String name, int value, int min, int max) {
    if (value < min || value > max) {
      throw QuranPositionException('قيمة $name يجب أن تكون بين $min و $max.');
    }
  }
}

class QuranPositionException implements FormatException {
  const QuranPositionException(this.message);

  @override
  final String message;

  @override
  int? get offset => null;

  @override
  Object? get source => null;

  @override
  String toString() => 'QuranPositionException: $message';
}
