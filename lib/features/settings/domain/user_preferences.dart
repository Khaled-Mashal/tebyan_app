import 'package:flutter/widgets.dart';

enum RaqeemVisualMode { light, night, system }

@immutable
class UserPreferences {
  const UserPreferences({
    required this.id,
    required this.onboardingCompleted,
    required this.languageCode,
    required this.visualMode,
    required this.createdAt,
    required this.updatedAt,
  });

  static const defaultId = 'default';
  static const supportedLanguageCodes = <String>{'ar', 'en'};

  final String id;
  final bool onboardingCompleted;
  final String languageCode;
  final RaqeemVisualMode visualMode;
  final DateTime createdAt;
  final DateTime updatedAt;

  TextDirection get textDirection =>
      languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;

  String get textDirectionName =>
      textDirection == TextDirection.rtl ? 'rtl' : 'ltr';

  factory UserPreferences.defaults({DateTime? now}) {
    final timestamp = now ?? DateTime.now().toUtc();
    return UserPreferences(
      id: defaultId,
      onboardingCompleted: false,
      languageCode: 'ar',
      visualMode: RaqeemVisualMode.light,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  UserPreferences copyWith({
    String? id,
    bool? onboardingCompleted,
    String? languageCode,
    RaqeemVisualMode? visualMode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final nextLanguageCode = languageCode ?? this.languageCode;
    _validateLanguageCode(nextLanguageCode);

    return UserPreferences(
      id: id ?? this.id,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      languageCode: nextLanguageCode,
      visualMode: visualMode ?? this.visualMode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'onboardingCompleted': onboardingCompleted,
      'languageCode': languageCode,
      'visualMode': visualMode.name,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  factory UserPreferences.fromJson(Map<String, Object?> json) {
    final languageCode = json['languageCode'] as String? ?? 'ar';
    _validateLanguageCode(languageCode);

    return UserPreferences(
      id: json['id'] as String? ?? defaultId,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      languageCode: languageCode,
      visualMode: _enumByName(
        RaqeemVisualMode.values,
        json['visualMode'] as String? ?? RaqeemVisualMode.light.name,
        'visualMode',
      ),
      createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
    );
  }

  static void _validateLanguageCode(String languageCode) {
    if (!supportedLanguageCodes.contains(languageCode)) {
      throw FormatException('Unsupported languageCode: $languageCode');
    }
  }

  static T _enumByName<T extends Enum>(
    Iterable<T> values,
    String name,
    String fieldName,
  ) {
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    throw FormatException('Unknown $fieldName value: $name');
  }

  @override
  bool operator ==(Object other) {
    return other is UserPreferences &&
        other.id == id &&
        other.onboardingCompleted == onboardingCompleted &&
        other.languageCode == languageCode &&
        other.visualMode == visualMode &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    onboardingCompleted,
    languageCode,
    visualMode,
    createdAt,
    updatedAt,
  );
}
