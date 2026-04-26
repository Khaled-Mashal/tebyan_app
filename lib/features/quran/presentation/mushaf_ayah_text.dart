import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart' as quran;

import '../../../app/theme/raqeem_theme.dart';
import '../domain/quran_position.dart';
import '../infrastructure/quran_gateway.dart';

class MushafAyahText extends StatefulWidget {
  const MushafAyahText({
    super.key,
    required this.position,
    required this.words,
    this.selectedWord,
    this.onSelectWord,
    this.showWordMeanings = false,
    this.height = 92,
    this.fontSize = 27,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
  });

  factory MushafAyahText.fromText({
    Key? key,
    required QuranPosition position,
    required String text,
    QuranWordSelection? selectedWord,
    ValueChanged<QuranAyahWord>? onSelectWord,
    bool showWordMeanings = false,
    double height = 92,
    double fontSize = 27,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 14,
    ),
  }) {
    final words = _splitAyahWords(text);
    return MushafAyahText(
      key: key,
      position: position,
      words: <QuranAyahWord>[
        for (var i = 0; i < words.length; i++)
          QuranAyahWord(
            selection: QuranWordSelection(
              position: position,
              wordNumber: i + 1,
            ),
            text: words[i],
          ),
      ],
      selectedWord: selectedWord,
      onSelectWord: onSelectWord,
      showWordMeanings: showWordMeanings,
      height: height,
      fontSize: fontSize,
      padding: padding,
    );
  }

  final QuranPosition position;
  final List<QuranAyahWord> words;
  final QuranWordSelection? selectedWord;
  final ValueChanged<QuranAyahWord>? onSelectWord;
  final bool showWordMeanings;
  final double height;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  @override
  State<MushafAyahText> createState() => _MushafAyahTextState();
}

class _MushafAyahTextState extends State<MushafAyahText> {
  late Future<List<_MushafGlyphWord>> _glyphWordsFuture;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(keepScrollOffset: false);
    _glyphWordsFuture = _loadGlyphWords();
    _resetScrollToRightEdge();
  }

  @override
  void didUpdateWidget(covariant MushafAyahText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.position != widget.position ||
        oldWidget.showWordMeanings != widget.showWordMeanings) {
      _glyphWordsFuture = _loadGlyphWords();
      _resetScrollToRightEdge();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
      child: Padding(
        padding: widget.padding,
        child: FutureBuilder<List<_MushafGlyphWord>>(
          future: _glyphWordsFuture,
          builder: (context, snapshot) {
            final glyphWords = snapshot.data ?? const <_MushafGlyphWord>[];
            if (glyphWords.isNotEmpty) {
              return _MushafGlyphStrip(
                position: widget.position,
                glyphWords: glyphWords,
                selectedWord: widget.selectedWord,
                onSelectWord: widget.onSelectWord,
                scrollController: _scrollController,
                height: widget.showWordMeanings
                    ? widget.height + 28
                    : widget.height,
                fontSize: widget.fontSize,
                showWordMeanings: widget.showWordMeanings,
              );
            }

            return _MushafPlainStrip(
              words: widget.words,
              selectedWord: widget.selectedWord,
              onSelectWord: widget.onSelectWord,
              scrollController: _scrollController,
              height: widget.showWordMeanings
                  ? widget.height + 28
                  : widget.height,
              fontSize: widget.fontSize,
              showWordMeanings: widget.showWordMeanings,
            );
          },
        ),
      ),
    );
  }

  Future<List<_MushafGlyphWord>> _loadGlyphWords() async {
    try {
      final ctrl = quran.QuranCtrl.instance;
      final pageNumber = widget.position.page;
      await quran.QuranFontsService.ensurePagesLoaded(pageNumber, radius: 0);
      final meanings = widget.showWordMeanings
          ? await quran.QpcHafsWordByWordAssetsLoader.load()
          : null;

      final blocks = ctrl.getQpcLayoutBlocksForPageSync(pageNumber);
      final glyphWords = <_MushafGlyphWord>[];
      for (final block in blocks) {
        if (block is! quran.QpcV4AyahLineBlock) continue;
        for (final segment in block.segments) {
          if (segment.surahNumber == widget.position.surahNumber &&
              segment.ayahNumber == widget.position.ayahNumber) {
            glyphWords.add(
              _MushafGlyphWord(
                wordNumber: segment.wordNumber,
                glyphs: segment.glyphs,
                meaning: meanings?.textFor(
                  surah: widget.position.surahNumber,
                  ayah: widget.position.ayahNumber,
                  word: segment.wordNumber,
                ),
                isAyahEnd: segment.isAyahEnd,
              ),
            );
          }
        }
      }
      return glyphWords;
    } catch (_) {
      return const <_MushafGlyphWord>[];
    }
  }

  void _resetScrollToRightEdge() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(0);
    });
  }
}

class _MushafPlainStrip extends StatelessWidget {
  const _MushafPlainStrip({
    required this.words,
    required this.selectedWord,
    required this.onSelectWord,
    required this.scrollController,
    required this.height,
    required this.fontSize,
    required this.showWordMeanings,
  });

  final List<QuranAyahWord> words;
  final QuranWordSelection? selectedWord;
  final ValueChanged<QuranAyahWord>? onSelectWord;
  final ScrollController scrollController;
  final double height;
  final double fontSize;
  final bool showWordMeanings;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('mushaf_word_scroller'),
      height: height,
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (final word in words)
              _MushafWordBox(
                key: Key('mushaf_word_${word.selection.wordNumber}'),
                textKey: Key('mushaf_word_text_${word.selection.wordNumber}'),
                text: word.text,
                meaningKey: Key(
                  'mushaf_word_meaning_${word.selection.wordNumber}',
                ),
                meaning: showWordMeanings ? word.text : null,
                fontSize: fontSize,
                selected: selectedWord?.wordNumber == word.selection.wordNumber,
                onTap: onSelectWord == null ? null : () => onSelectWord!(word),
              ),
          ],
        ),
      ),
    );
  }
}

class _MushafGlyphStrip extends StatelessWidget {
  const _MushafGlyphStrip({
    required this.position,
    required this.glyphWords,
    required this.selectedWord,
    required this.onSelectWord,
    required this.scrollController,
    required this.height,
    required this.fontSize,
    required this.showWordMeanings,
  });

  final QuranPosition position;
  final List<_MushafGlyphWord> glyphWords;
  final QuranWordSelection? selectedWord;
  final ValueChanged<QuranAyahWord>? onSelectWord;
  final ScrollController scrollController;
  final double height;
  final double fontSize;
  final bool showWordMeanings;

  @override
  Widget build(BuildContext context) {
    final pageIndex = position.page - 1;
    final fontFamily = quran.QuranCtrl.instance.getFontPath(
      pageIndex,
      isDark: false,
    );

    return SizedBox(
      key: const Key('mushaf_word_scroller'),
      height: height,
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (final glyphWord in glyphWords)
              Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: TextDirection.rtl,
                children: [
                  _MushafWordBox(
                    key: Key('mushaf_word_${glyphWord.wordNumber}'),
                    textKey: Key('mushaf_word_text_${glyphWord.wordNumber}'),
                    text: glyphWord.glyphs,
                    meaningKey: Key(
                      'mushaf_word_meaning_${glyphWord.wordNumber}',
                    ),
                    meaning: showWordMeanings ? glyphWord.meaning : null,
                    fontFamily: fontFamily,
                    fontSize: fontSize,
                    selected: selectedWord?.wordNumber == glyphWord.wordNumber,
                    onTap: onSelectWord == null
                        ? null
                        : () => onSelectWord!(
                            QuranAyahWord(
                              selection: QuranWordSelection(
                                position: position,
                                wordNumber: glyphWord.wordNumber,
                              ),
                              text: glyphWord.glyphs,
                            ),
                          ),
                  ),
                  if (glyphWord.isAyahEnd)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 4),
                      child: _AyahEndNumber(
                        ayahNumber: position.ayahNumber,
                        fontSize: fontSize,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _MushafWordBox extends StatelessWidget {
  const _MushafWordBox({
    super.key,
    this.textKey,
    required this.text,
    this.meaningKey,
    this.meaning,
    this.fontFamily,
    required this.fontSize,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final Key? textKey;
  final String? meaning;
  final Key? meaningKey;
  final String? fontFamily;
  final double fontSize;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const selectedColor = Color(0xFF1E88D8);
    final wordText = Text(
      key: textKey,
      text,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: fontFamily,
        color: selected ? selectedColor : const Color(0xFF221512),
        fontSize: fontSize,
        height: fontFamily == null ? 1.55 : 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
    );

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: EdgeInsets.fromLTRB(7, 8, 7, meaning == null ? 10 : 7),
      constraints: const BoxConstraints(minHeight: 54, minWidth: 38),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(RaqeemRadii.small),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (selected)
            _ForcedGlyphColor(color: selectedColor, child: wordText),
          if (!selected) wordText,
          if (meaning != null && meaning!.trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 96),
              child: Text(
                key: meaningKey,
                meaning!.trim(),
                textDirection: _directionFor(meaning!),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? selectedColor
                      : RaqeemColors.secondaryText.withValues(alpha: 0.86),
                  fontSize: 10,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return content;

    return Semantics(
      selected: selected,
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: content,
        ),
      ),
    );
  }
}

class _AyahEndNumber extends StatelessWidget {
  const _AyahEndNumber({required this.ayahNumber, required this.fontSize});

  final int ayahNumber;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${_toArabicDigits(ayahNumber.toString())}\u202F\u202F',
      textDirection: TextDirection.rtl,
      style: TextStyle(
        fontFamily: 'ayahNumber',
        package: 'quran_library',
        color: RaqeemColors.primary,
        fontSize: fontSize + 5,
        height: 1.5,
      ),
    );
  }
}

class _ForcedGlyphColor extends StatelessWidget {
  const _ForcedGlyphColor({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return LinearGradient(colors: [color, color]).createShader(bounds);
      },
      child: child,
    );
  }
}

class _MushafGlyphWord {
  const _MushafGlyphWord({
    required this.wordNumber,
    required this.glyphs,
    this.meaning,
    required this.isAyahEnd,
  });

  final int wordNumber;
  final String glyphs;
  final String? meaning;
  final bool isAyahEnd;
}

TextDirection _directionFor(String text) {
  return RegExp(r'[A-Za-z]').hasMatch(text)
      ? TextDirection.ltr
      : TextDirection.rtl;
}

String _toArabicDigits(String text) {
  const english = '0123456789';
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  return text.split('').map((char) {
    final index = english.indexOf(char);
    return index == -1 ? char : arabic[index];
  }).join();
}

List<String> _splitAyahWords(String text) {
  return text
      .replaceAll(RegExp(r'[\u06DD۝﴿﴾]'), ' ')
      .split(RegExp(r'\s+'))
      .map((word) => word.trim())
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
}
