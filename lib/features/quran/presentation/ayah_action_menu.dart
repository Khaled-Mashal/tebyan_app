import 'package:flutter/material.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/raqeem_theme.dart';
import '../domain/quran_position.dart';
import '../infrastructure/quran_gateway.dart';
import 'mushaf_ayah_text.dart';

enum AyahAction {
  playAudio,
  openTafsir,
  openTranslation,
  bookmark,
  addNote,
  copyText,
  shareText,
  shareImage,
  setWirdStart,
  setWirdEnd,
}

class AyahActionMenu extends StatefulWidget {
  const AyahActionMenu({
    super.key,
    required this.position,
    this.selectedAyah,
    this.audioGateway,
    this.wordGateway,
  });

  final QuranPosition position;
  final SelectedAyah? selectedAyah;
  final QuranAudioGateway? audioGateway;
  final QuranWordGateway? wordGateway;

  static Future<AyahAction?> show(
    BuildContext context, {
    required QuranPosition position,
    SelectedAyah? selectedAyah,
    QuranAudioGateway? audioGateway,
    QuranWordGateway? wordGateway,
  }) {
    return showModalBottomSheet<AyahAction>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: RaqeemColors.softWhite,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AyahActionMenu(
        position: position,
        selectedAyah: selectedAyah,
        audioGateway: audioGateway,
        wordGateway: wordGateway,
      ),
    );
  }

  @override
  State<AyahActionMenu> createState() => _AyahActionMenuState();
}

class _AyahActionMenuState extends State<AyahActionMenu> {
  late Future<List<QuranAyahWord>> _wordsFuture;
  QuranWordSelection? _selectedWord;
  QuranWordInfoKind _selectedKind = QuranWordInfoKind.recitations;
  Future<QuranWordInfoResult>? _wordInfoFuture;
  bool _showWordMeanings = false;

  @override
  void initState() {
    super.initState();
    _wordsFuture = _loadWords();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title =
        '${widget.position.displaySurahName} ${widget.position.ayahNumber}';

    return Directionality(
      textDirection: l10n.textDirection,
      child: DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.48,
        maxChildSize: 0.96,
        expand: false,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
            children: [
              const _SheetHandle(),
              _SheetHeader(
                title: title,
                subtitle: widget.selectedAyah?.reference,
                onClose: () => Navigator.of(context).pop(),
                closeTooltip: l10n.closeSelection,
              ),
              const SizedBox(height: 10),
              _MushafWordLoader(
                wordsFuture: _wordsFuture,
                selectedWord: _selectedWord,
                showWordMeanings: _showWordMeanings,
                onSelectWord: _selectWord,
                loadingLabel: _label(l10n, 'جاري تجهيز نص الآية', 'Loading'),
                emptyLabel: _label(
                  l10n,
                  'لا توجد كلمات قابلة للتحديد',
                  'No selectable words',
                ),
              ),
              const SizedBox(height: 10),
              _ReaderToolbar(
                l10n: l10n,
                onPlayAyah: () =>
                    Navigator.of(context).pop(AyahAction.playAudio),
                onPlayWord: _selectedWord == null || widget.wordGateway == null
                    ? null
                    : () => _runWordAction(
                        () => widget.wordGateway!.playWordAudio(_selectedWord!),
                      ),
                onPlayAyahWords: widget.wordGateway == null
                    ? null
                    : () => _runWordAction(
                        () => widget.wordGateway!.playAyahWordsAudio(
                          widget.position,
                        ),
                      ),
                onTafsir: () =>
                    Navigator.of(context).pop(AyahAction.openTafsir),
                isTranslationActive: _showWordMeanings,
                onToggleTranslation: () {
                  setState(() => _showWordMeanings = !_showWordMeanings);
                },
              ),
              const SizedBox(height: 10),
              _WordInfoSurface(
                selectedKind: _selectedKind,
                selectedWord: _selectedWord,
                wordInfoFuture: _wordInfoFuture,
                onKindChanged: _changeKind,
                onDownload: widget.wordGateway == null || _selectedWord == null
                    ? null
                    : _downloadSelectedKind,
                l10n: l10n,
              ),
              const SizedBox(height: 12),
              _SecondaryActions(l10n: l10n),
            ],
          );
        },
      ),
    );
  }

  Future<List<QuranAyahWord>> _loadWords() async {
    final gateway = widget.wordGateway;
    if (gateway != null) {
      final words = await gateway.getAyahWords(widget.position);
      if (words.isNotEmpty) _setInitialWord(words.first.selection);
      return words;
    }

    final words = _splitAyahWords(widget.selectedAyah?.text ?? '');
    final mapped = <QuranAyahWord>[
      for (var i = 0; i < words.length; i++)
        QuranAyahWord(
          selection: QuranWordSelection(
            position: widget.position,
            wordNumber: i + 1,
          ),
          text: words[i],
        ),
    ];
    if (mapped.isNotEmpty) _setInitialWord(mapped.first.selection);
    return mapped;
  }

  void _setInitialWord(QuranWordSelection selection) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selectedWord != null) return;
      setState(() {
        _selectedWord = selection;
        _wordInfoFuture = _loadWordInfo();
      });
    });
  }

  void _selectWord(QuranAyahWord word) {
    setState(() {
      _selectedWord = word.selection;
      _wordInfoFuture = _loadWordInfo();
    });
  }

  void _changeKind(QuranWordInfoKind kind) {
    setState(() {
      _selectedKind = kind;
      _wordInfoFuture = _loadWordInfo();
    });
  }

  Future<QuranWordInfoResult> _loadWordInfo() {
    final gateway = widget.wordGateway;
    final word = _selectedWord;
    if (gateway == null || word == null) {
      return Future.value(
        QuranWordInfoResult(
          kind: _selectedKind,
          availability: AvailabilityState.unsupported,
        ),
      );
    }
    return gateway.getWordInfo(word, kind: _selectedKind);
  }

  Future<void> _downloadSelectedKind() async {
    final gateway = widget.wordGateway;
    if (gateway == null) return;
    setState(() {
      _wordInfoFuture = _downloadAndReload(gateway);
    });
  }

  Future<QuranWordInfoResult> _downloadAndReload(
    QuranWordGateway gateway,
  ) async {
    await gateway.downloadWordInfoKind(_selectedKind);
    return _loadWordInfo();
  }

  Future<void> _runWordAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر تنفيذ إجراء الكلمة.')));
    }
  }

  List<String> _splitAyahWords(String text) {
    return text
        .replaceAll(RegExp(r'[\u06DD۝﴿﴾]'), ' ')
        .split(RegExp(r'\s+'))
        .map((word) => word.trim())
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: RaqeemColors.secondaryText.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.title,
    required this.onClose,
    required this.closeTooltip,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onClose;
  final String closeTooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              key: const Key('close_ayah_action_sheet'),
              icon: const Icon(Icons.close, size: 20),
              onPressed: onClose,
              tooltip: closeTooltip,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: RaqeemColors.primaryText,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: RaqeemColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MushafWordLoader extends StatelessWidget {
  const _MushafWordLoader({
    required this.wordsFuture,
    required this.selectedWord,
    required this.showWordMeanings,
    required this.onSelectWord,
    required this.loadingLabel,
    required this.emptyLabel,
  });

  final Future<List<QuranAyahWord>> wordsFuture;
  final QuranWordSelection? selectedWord;
  final bool showWordMeanings;
  final ValueChanged<QuranAyahWord> onSelectWord;
  final String loadingLabel;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QuranAyahWord>>(
      future: wordsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _MushafMessageBox(label: loadingLabel);
        }

        final words = snapshot.data ?? const <QuranAyahWord>[];
        if (words.isEmpty) {
          return _MushafMessageBox(label: emptyLabel);
        }

        return MushafAyahText(
          position: words.first.selection.position,
          words: words,
          selectedWord: selectedWord,
          showWordMeanings: showWordMeanings,
          onSelectWord: onSelectWord,
        );
      },
    );
  }
}

class _MushafMessageBox extends StatelessWidget {
  const _MushafMessageBox({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RaqeemColors.background,
        border: Border.all(
          color: RaqeemColors.accentGold.withValues(alpha: 0.32),
        ),
        borderRadius: BorderRadius.circular(RaqeemRadii.medium),
      ),
      child: SizedBox(
        height: 82,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: RaqeemColors.secondaryText,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReaderToolbar extends StatelessWidget {
  const _ReaderToolbar({
    required this.l10n,
    required this.onPlayAyah,
    required this.onPlayWord,
    required this.onPlayAyahWords,
    required this.onTafsir,
    required this.isTranslationActive,
    required this.onToggleTranslation,
  });

  final AppLocalizations l10n;
  final VoidCallback onPlayAyah;
  final VoidCallback? onPlayWord;
  final VoidCallback? onPlayAyahWords;
  final VoidCallback onTafsir;
  final bool isTranslationActive;
  final VoidCallback onToggleTranslation;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        _ToolButton(
          icon: Icons.play_arrow_rounded,
          label: l10n.playAudio,
          tooltip: l10n.playAudio,
          onTap: onPlayAyah,
        ),
        _ToolButton(
          icon: Icons.volume_up_rounded,
          label: _label(l10n, 'الكلمة', 'Word'),
          tooltip: _label(l10n, 'تشغيل الكلمة', 'Play word'),
          onTap: onPlayWord,
        ),
        _ToolButton(
          icon: Icons.graphic_eq_rounded,
          label: _label(l10n, 'تلاوة الكلمات', 'Words'),
          tooltip: _label(l10n, 'تشغيل كلمات الآية', 'Play ayah words'),
          onTap: onPlayAyahWords,
        ),
        _ToolButton(
          icon: Icons.menu_book_outlined,
          label: l10n.openTafsir,
          tooltip: l10n.openTafsir,
          onTap: onTafsir,
        ),
        _ToolButton(
          icon: Icons.translate_rounded,
          label: l10n.openTranslation,
          tooltip: l10n.openTranslation,
          active: isTranslationActive,
          onTap: onToggleTranslation,
        ),
      ],
    );
  }
}

class _WordInfoSurface extends StatelessWidget {
  const _WordInfoSurface({
    required this.selectedKind,
    required this.selectedWord,
    required this.wordInfoFuture,
    required this.onKindChanged,
    required this.onDownload,
    required this.l10n,
  });

  final QuranWordInfoKind selectedKind;
  final QuranWordSelection? selectedWord;
  final Future<QuranWordInfoResult>? wordInfoFuture;
  final ValueChanged<QuranWordInfoKind> onKindChanged;
  final VoidCallback? onDownload;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RaqeemColors.surface,
        borderRadius: BorderRadius.circular(RaqeemRadii.medium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _KindSegmentedControl(
              selected: selectedKind,
              onChanged: onKindChanged,
              l10n: l10n,
            ),
            const SizedBox(height: 10),
            if (selectedWord == null)
              _InfoMessage(
                icon: Icons.touch_app_outlined,
                text: _label(
                  l10n,
                  'اضغط على كلمة من نص الآية لعرض بياناتها.',
                  'Tap a word to view its details.',
                ),
              )
            else
              FutureBuilder<QuranWordInfoResult>(
                future: wordInfoFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 96,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: RaqeemColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }

                  final result = snapshot.data;
                  if (snapshot.hasError || result == null) {
                    return _InfoMessage(
                      icon: Icons.error_outline_rounded,
                      text: _label(
                        l10n,
                        'تعذر تحميل بيانات الكلمة.',
                        'Word details could not be loaded.',
                      ),
                    );
                  }

                  if (result.availability == AvailabilityState.unavailable) {
                    return _UnavailableWordInfo(
                      label: _unavailableLabel(result.kind, l10n),
                      onDownload: onDownload,
                      downloadLabel: _label(l10n, 'تحميل البيانات', 'Download'),
                    );
                  }

                  if (!result.hasContent) {
                    return _InfoMessage(
                      icon: Icons.info_outline_rounded,
                      text: _label(
                        l10n,
                        'لا توجد بيانات لهذه الكلمة في هذا القسم.',
                        'No details for this word in this section.',
                      ),
                    );
                  }

                  return _WordInfoText(result: result);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _KindSegmentedControl extends StatelessWidget {
  const _KindSegmentedControl({
    required this.selected,
    required this.onChanged,
    required this.l10n,
  });

  final QuranWordInfoKind selected;
  final ValueChanged<QuranWordInfoKind> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KindSegment(
            label: _label(l10n, 'القراءات', 'Readings'),
            selected: selected == QuranWordInfoKind.recitations,
            onTap: () => onChanged(QuranWordInfoKind.recitations),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _KindSegment(
            label: _label(l10n, 'التصريف', 'Morphology'),
            selected: selected == QuranWordInfoKind.morphology,
            onTap: () => onChanged(QuranWordInfoKind.morphology),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _KindSegment(
            label: _label(l10n, 'الإعراب', 'Grammar'),
            selected: selected == QuranWordInfoKind.grammar,
            onTap: () => onChanged(QuranWordInfoKind.grammar),
          ),
        ),
      ],
    );
  }
}

class _KindSegment extends StatelessWidget {
  const _KindSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? RaqeemColors.primary : RaqeemColors.softWhite,
      borderRadius: BorderRadius.circular(RaqeemRadii.small),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RaqeemRadii.small),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected
                  ? RaqeemColors.softWhite
                  : RaqeemColors.primaryText,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _WordInfoText extends StatelessWidget {
  const _WordInfoText({required this.result});

  final QuranWordInfoResult result;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RaqeemColors.softWhite,
        borderRadius: BorderRadius.circular(RaqeemRadii.small),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (result.word != null && result.word!.trim().isNotEmpty) ...[
              Text(
                result.word!,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: RaqeemColors.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              result.content!.trim(),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: RaqeemColors.primaryText,
                fontSize: 15,
                height: 1.75,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnavailableWordInfo extends StatelessWidget {
  const _UnavailableWordInfo({
    required this.label,
    required this.onDownload,
    required this.downloadLabel,
  });

  final String label;
  final VoidCallback? onDownload;
  final String downloadLabel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RaqeemColors.softWhite,
        borderRadius: BorderRadius.circular(RaqeemRadii.small),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.cloud_download_outlined,
              color: RaqeemColors.secondaryText.withValues(alpha: 0.75),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: RaqeemColors.primaryText,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onDownload,
              style: FilledButton.styleFrom(
                minimumSize: const Size(44, 38),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(downloadLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoMessage extends StatelessWidget {
  const _InfoMessage({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: RaqeemColors.secondaryText),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: RaqeemColors.secondaryText,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryActions extends StatelessWidget {
  const _SecondaryActions({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        _ToolButton(
          icon: Icons.bookmark_outline_rounded,
          label: l10n.addBookmark,
          tooltip: l10n.addBookmark,
          onTap: () => Navigator.of(context).pop(AyahAction.bookmark),
        ),
        _ToolButton(
          icon: Icons.note_add_outlined,
          label: l10n.addNote,
          tooltip: l10n.addNote,
          onTap: () => Navigator.of(context).pop(AyahAction.addNote),
        ),
        _ToolButton(
          icon: Icons.copy_rounded,
          label: l10n.copyAyahText,
          tooltip: l10n.copyAyahText,
          onTap: () => Navigator.of(context).pop(AyahAction.copyText),
        ),
        _ToolButton(
          icon: Icons.ios_share_rounded,
          label: l10n.shareAyahText,
          tooltip: l10n.shareAyahText,
          onTap: () => Navigator.of(context).pop(AyahAction.shareText),
        ),
        _ToolButton(
          icon: Icons.image_outlined,
          label: l10n.shareAsImage,
          tooltip: l10n.shareAsImage,
          onTap: () => Navigator.of(context).pop(AyahAction.shareImage),
        ),
        _ToolButton(
          icon: Icons.flag_outlined,
          label: l10n.setWirdStart,
          tooltip: l10n.setWirdStart,
          onTap: () => Navigator.of(context).pop(AyahAction.setWirdStart),
        ),
        _ToolButton(
          icon: Icons.flag_rounded,
          label: l10n.setWirdEnd,
          tooltip: l10n.setWirdEnd,
          onTap: () => Navigator.of(context).pop(AyahAction.setWirdEnd),
        ),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active
          ? const Color(0xFFE5F2FC)
          : onTap == null
          ? RaqeemColors.surface
          : RaqeemColors.background,
      borderRadius: BorderRadius.circular(RaqeemRadii.medium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RaqeemRadii.medium),
        child: Tooltip(
          message: tooltip,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 74,
              maxWidth: 132,
              minHeight: 44,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: onTap == null
                        ? RaqeemColors.secondaryText.withValues(alpha: 0.45)
                        : active
                        ? const Color(0xFF1E88D8)
                        : RaqeemColors.primary,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: onTap == null
                            ? RaqeemColors.secondaryText.withValues(alpha: 0.55)
                            : active
                            ? const Color(0xFF1E88D8)
                            : RaqeemColors.primaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _unavailableLabel(QuranWordInfoKind kind, AppLocalizations l10n) {
  return switch (kind) {
    QuranWordInfoKind.recitations => _label(
      l10n,
      'بيانات القراءات غير محملة لهذا المصحف.',
      'Reading data is not downloaded.',
    ),
    QuranWordInfoKind.morphology => _label(
      l10n,
      'بيانات التصريف غير محملة بعد.',
      'Morphology data is not downloaded.',
    ),
    QuranWordInfoKind.grammar => _label(
      l10n,
      'بيانات الإعراب غير محملة بعد.',
      'Grammar data is not downloaded.',
    ),
  };
}

String _label(AppLocalizations l10n, String ar, String en) {
  return l10n.isArabic ? ar : en;
}
