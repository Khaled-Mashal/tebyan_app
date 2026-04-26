import 'package:flutter/material.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/raqeem_theme.dart';
import '../../quran/domain/quran_position.dart';
import '../domain/ayah_share_draft.dart';

class SharePreviewScreen extends StatefulWidget {
  const SharePreviewScreen({
    super.key,
    required this.position,
    this.onShareImage,
  });

  final QuranPosition position;
  final Future<void> Function(AyahShareDraft draft)? onShareImage;

  @override
  State<SharePreviewScreen> createState() => _SharePreviewScreenState();
}

class _SharePreviewScreenState extends State<SharePreviewScreen> {
  ShareFormat _format = ShareFormat.squareImage;
  ShareTheme _theme = ShareTheme.parchment;
  bool _includeTranslation = false;
  bool _includeTafsir = false;
  final BrandPlacement _brandPlacement = BrandPlacement.footer;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shareAsImage)),
      body: ListView(
        padding: const EdgeInsets.all(RaqeemSpacing.medium),
        children: [
          _AyahPreviewCard(
            position: widget.position,
            theme: _theme,
            format: _format,
          ),
          const SizedBox(height: RaqeemSpacing.large),
          _SectionHeader(label: l10n.shareAsImage),
          const SizedBox(height: RaqeemSpacing.small),
          _FormatSelector(
            selectedFormat: _format,
            onFormatChanged: (format) => setState(() => _format = format),
          ),
          const SizedBox(height: RaqeemSpacing.medium),
          _ThemeSelector(
            selectedTheme: _theme,
            onThemeChanged: (theme) => setState(() => _theme = theme),
          ),
          const SizedBox(height: RaqeemSpacing.medium),
          SwitchListTile(
            value: _includeTranslation,
            onChanged: (v) => setState(() => _includeTranslation = v),
            title: Text(
              l10n.openTranslation,
              style: const TextStyle(
                color: RaqeemColors.primaryText,
                fontSize: 14,
              ),
            ),
            activeThumbColor: RaqeemColors.primary,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: _includeTafsir,
            onChanged: (v) => setState(() => _includeTafsir = v),
            title: Text(
              l10n.openTafsir,
              style: const TextStyle(
                color: RaqeemColors.primaryText,
                fontSize: 14,
              ),
            ),
            activeThumbColor: RaqeemColors.primary,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: RaqeemSpacing.large),
          if (_isGenerating)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(RaqeemSpacing.medium),
                child: CircularProgressIndicator(color: RaqeemColors.primary),
              ),
            )
          else
            FilledButton(onPressed: _share, child: Text(l10n.shareAyahText)),
        ],
      ),
    );
  }

  Future<void> _share() async {
    setState(() => _isGenerating = true);
    final now = DateTime.now().toUtc();
    final draft = AyahShareDraft(
      id: 'share-${now.millisecondsSinceEpoch}',
      position: widget.position,
      format: _format,
      includeTranslation: _includeTranslation,
      includeTafsir: _includeTafsir,
      theme: _theme,
      brandPlacement: _brandPlacement,
      createdAt: now,
      updatedAt: now,
    );
    try {
      await widget.onShareImage?.call(draft);
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}

class _AyahPreviewCard extends StatelessWidget {
  const _AyahPreviewCard({
    required this.position,
    required this.theme,
    required this.format,
  });

  final QuranPosition position;
  final ShareTheme theme;
  final ShareFormat format;

  @override
  Widget build(BuildContext context) {
    final bgColor = switch (theme) {
      ShareTheme.light => RaqeemColors.background,
      ShareTheme.night => RaqeemColors.nightBackground,
      ShareTheme.parchment => RaqeemColors.softWhite,
    };

    final textColor = switch (theme) {
      ShareTheme.light => RaqeemColors.primaryText,
      ShareTheme.night => RaqeemColors.nightText,
      ShareTheme.parchment => RaqeemColors.primaryText,
    };

    final height = switch (format) {
      ShareFormat.squareImage => 280.0,
      ShareFormat.storyImage => 400.0,
      ShareFormat.portraitImage => 360.0,
      ShareFormat.text => 120.0,
    };

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(RaqeemRadii.medium),
        border: Border.all(
          color: RaqeemColors.secondaryText.withValues(alpha: 0.15),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(RaqeemSpacing.large),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                position.displaySurahName,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${position.surahNumber}:${position.ayahNumber}',
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: RaqeemColors.primaryText,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _FormatSelector extends StatelessWidget {
  const _FormatSelector({
    required this.selectedFormat,
    required this.onFormatChanged,
  });

  final ShareFormat selectedFormat;
  final ValueChanged<ShareFormat> onFormatChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ShareFormat>(
      segments: const [
        ButtonSegment(value: ShareFormat.squareImage, label: Text('مربع')),
        ButtonSegment(value: ShareFormat.storyImage, label: Text('قصّة')),
        ButtonSegment(value: ShareFormat.portraitImage, label: Text('طولي')),
      ],
      selected: {selectedFormat},
      onSelectionChanged: (s) => onFormatChanged(s.first),
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return RaqeemColors.primary;
          }
          return RaqeemColors.surface;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return RaqeemColors.softWhite;
          }
          return RaqeemColors.primaryText;
        }),
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({
    required this.selectedTheme,
    required this.onThemeChanged,
  });

  final ShareTheme selectedTheme;
  final ValueChanged<ShareTheme> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ShareTheme.values.map((theme) {
        final isSelected = theme == selectedTheme;
        final color = switch (theme) {
          ShareTheme.light => RaqeemColors.background,
          ShareTheme.night => RaqeemColors.nightBackground,
          ShareTheme.parchment => RaqeemColors.softWhite,
        };
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: InkWell(
            onTap: () => onThemeChanged(theme),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? RaqeemColors.primary
                      : RaqeemColors.secondaryText.withValues(alpha: 0.3),
                  width: isSelected ? 2.5 : 1,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
