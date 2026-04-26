import 'package:flutter/material.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/raqeem_theme.dart';
import '../domain/quran_position.dart';
import '../infrastructure/quran_gateway.dart';
import 'mushaf_ayah_text.dart';

class ExplanationSheet extends StatelessWidget {
  const ExplanationSheet({
    super.key,
    required this.position,
    required this.mode,
    this.explanationGateway,
    this.selectedAyah,
  });

  final QuranPosition position;
  final ExplanationMode mode;
  final QuranExplanationGateway? explanationGateway;
  final SelectedAyah? selectedAyah;

  static Future<void> showTafsir(
    BuildContext context, {
    required QuranPosition position,
    QuranExplanationGateway? explanationGateway,
    SelectedAyah? selectedAyah,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: RaqeemColors.softWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ExplanationSheet(
        position: position,
        mode: ExplanationMode.tafsir,
        explanationGateway: explanationGateway,
        selectedAyah: selectedAyah,
      ),
    );
  }

  static Future<void> showTranslation(
    BuildContext context, {
    required QuranPosition position,
    QuranExplanationGateway? explanationGateway,
    SelectedAyah? selectedAyah,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: RaqeemColors.softWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ExplanationSheet(
        position: position,
        mode: ExplanationMode.translation,
        explanationGateway: explanationGateway,
        selectedAyah: selectedAyah,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = mode == ExplanationMode.tafsir
        ? l10n.openTafsir
        : l10n.openTranslation;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: RaqeemColors.secondaryText.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: RaqeemColors.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${position.displaySurahName} ${position.ayahNumber}',
                          style: const TextStyle(
                            color: RaqeemColors.secondaryText,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      tooltip: l10n.closeSelection,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 24,
              indent: 16,
              endIndent: 16,
              color: RaqeemColors.surface,
            ),
            Expanded(
              child: FutureBuilder<List<ExplanationEntry>>(
                future: _loadExplanation(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: RaqeemColors.primary,
                        strokeWidth: 2.5,
                      ),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(RaqeemSpacing.large),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_off_outlined,
                              size: 36,
                              color: RaqeemColors.secondaryText.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              mode == ExplanationMode.tafsir
                                  ? 'التفسير غير متاح حاليًا'
                                  : 'الترجمة غير متاحة حاليًا',
                              style: const TextStyle(
                                color: RaqeemColors.secondaryText,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final entries = snapshot.data!;
                  if (entries.isEmpty) {
                    return Center(
                      child: Text(
                        mode == ExplanationMode.tafsir
                            ? 'لا يوجد تفسير متاح لهذه الآية'
                            : 'لا توجد ترجمة متاحة لهذه الآية',
                        style: const TextStyle(
                          color: RaqeemColors.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }

                  final hasAyahHeader = selectedAyah != null;
                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: entries.length + (hasAyahHeader ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (hasAyahHeader && index == 0) {
                        return _ExplanationAyahHeader(
                          position: position,
                          selectedAyah: selectedAyah!,
                        );
                      }

                      final entry = entries[index - (hasAyahHeader ? 1 : 0)];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (entry.sourceName != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  entry.sourceName!,
                                  style: const TextStyle(
                                    color: RaqeemColors.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            Text(
                              entry.text,
                              style: const TextStyle(
                                color: RaqeemColors.primaryText,
                                fontSize: 15,
                                height: 1.7,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<ExplanationEntry>> _loadExplanation(BuildContext context) async {
    final gateway = explanationGateway;
    if (gateway == null) return [];

    try {
      if (mode == ExplanationMode.tafsir) {
        final entries = await gateway.getTafsir(position);
        return entries
            .map(
              (entry) => ExplanationEntry(
                sourceName: entry.sourceName,
                text: entry.hasContent
                    ? entry.text
                    : 'مصدر التفسير غير محمل بعد.',
                availability: entry.availability,
              ),
            )
            .toList();
      }

      final entries = await gateway.getTranslation(position);
      return entries
          .map(
            (entry) => ExplanationEntry(
              sourceName: entry.sourceName,
              text: entry.hasContent
                  ? entry.text
                  : 'مصدر الترجمة غير محمل بعد.',
              availability: entry.availability,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }
}

enum ExplanationMode { tafsir, translation }

class _ExplanationAyahHeader extends StatelessWidget {
  const _ExplanationAyahHeader({
    required this.position,
    required this.selectedAyah,
  });

  final QuranPosition position;
  final SelectedAyah selectedAyah;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: MushafAyahText.fromText(
        key: const Key('explanation_mushaf_ayah'),
        position: position,
        text: selectedAyah.text,
        height: 82,
        fontSize: 25,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      ),
    );
  }
}

class ExplanationEntry {
  const ExplanationEntry({
    this.sourceName,
    required this.text,
    this.availability = AvailabilityState.available,
  });

  final String? sourceName;
  final String text;
  final AvailabilityState availability;
}
