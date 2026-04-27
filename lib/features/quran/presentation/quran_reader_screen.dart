import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/raqeem_theme.dart';
import '../../../shared/errors/app_error.dart';
import '../../../shared/platform/share_gateway.dart';
import '../../bookmarks/application/bookmark_editor_view_model.dart';
import '../../bookmarks/domain/bookmark_annotation.dart';
import '../../bookmarks/infrastructure/bookmark_repository.dart';
import '../../sharing/application/ayah_sharing_service.dart';
import '../../sharing/presentation/share_preview_screen.dart';
import '../application/reader_position_service.dart';
import '../application/reader_state.dart';
import '../application/navigation_selector_view_model.dart';
import '../application/reader_view_model.dart';
import '../domain/quran_position.dart';
import '../infrastructure/quran_gateway.dart';
import '../infrastructure/quran_reader_widget_factory.dart';
import 'ayah_action_menu.dart';
import 'explanation_sheet.dart';
import 'navigation_selector_sheet.dart';
import 'raqeem_reader_style.dart';

class QuranReaderScreen extends StatelessWidget {
  const QuranReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReaderViewModel>();
    final state = viewModel.state;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: RaqeemColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            switch (state.status) {
              ReaderStatus.loading => _LoadingView(l10n: l10n),
              ReaderStatus.ready => _ReadyView(
                state: state,
                viewModel: viewModel,
                l10n: l10n,
              ),
              ReaderStatus.error => _ErrorView(
                error: state.error,
                l10n: l10n,
                onRetry: () {
                  final position = state.position;
                  if (position != null) {
                    viewModel.openAtPosition(position);
                  }
                },
              ),
            },
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: RaqeemColors.primary,
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.readerLoading,
            style: const TextStyle(
              color: RaqeemColors.secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadyView extends StatelessWidget {
  const _ReadyView({
    required this.state,
    required this.viewModel,
    required this.l10n,
  });

  final ReaderState state;
  final ReaderViewModel viewModel;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await viewModel.saveLastPosition();
        if (context.mounted) Navigator.of(context).pop();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: viewModel.toggleControls,
        child: Stack(
          children: [
            _QuranReaderBody(
              viewModel: viewModel,
              l10n: l10n,
              onAyahSelected: (position) => _showAyahActions(context, position),
            ),
            if (state.areControlsVisible) ...[
              _TopControlsBar(viewModel: viewModel, l10n: l10n),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showAyahActions(
    BuildContext context,
    QuranPosition selectedPos,
  ) async {
    final selectionGateway = _tryRead<QuranSelectionGateway>(context);
    final explanationGateway = _tryRead<QuranExplanationGateway>(context);
    final audioGateway = _tryRead<QuranAudioGateway>(context);
    final wordGateway = _tryRead<QuranWordGateway>(context);
    final bookmarkRepo = _tryRead<BookmarkRepository>(context);
    final shareGateway = _tryRead<ShareGateway>(context);
    final navigator = Navigator.of(context);
    SelectedAyah? selectedAyah;
    if (selectionGateway != null) {
      try {
        selectedAyah = await selectionGateway.getSelectedAyah(selectedPos);
      } catch (_) {}
    }
    if (!context.mounted) return;

    final action = await AyahActionMenu.show(
      context,
      position: selectedPos,
      selectedAyah: selectedAyah,
      audioGateway: audioGateway,
      wordGateway: wordGateway,
    );
    if (action == null) return;
    if (!context.mounted) return;

    switch (action) {
      case AyahAction.playAudio:
        await audioGateway?.playAyahAudio(context, selectedPos);
      case AyahAction.openTafsir:
        ExplanationSheet.showTafsir(
          context,
          position: selectedPos,
          explanationGateway: explanationGateway,
          selectedAyah: selectedAyah,
        );
      case AyahAction.openTranslation:
        ExplanationSheet.showTranslation(
          context,
          position: selectedPos,
          explanationGateway: explanationGateway,
          selectedAyah: selectedAyah,
        );
      case AyahAction.bookmark:
        if (bookmarkRepo != null) {
          _saveQuickBookmark(context, selectedPos, bookmarkRepo);
        }
      case AyahAction.addNote:
        if (bookmarkRepo != null) {
          _saveBookmarkWithNote(context, selectedPos, bookmarkRepo);
        }
      case AyahAction.copyText:
        await selectionGateway?.copyAyah(selectedPos);
      case AyahAction.shareText:
        if (selectionGateway != null && shareGateway != null) {
          final service = AyahSharingService(
            selectionGateway: selectionGateway,
            shareGateway: shareGateway,
          );
          service.shareAyahText(selectedPos);
        }
      case AyahAction.shareImage:
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => SharePreviewScreen(
              position: selectedPos,
              onShareImage: (draft) async {
                if (selectionGateway != null && shareGateway != null) {
                  final service = AyahSharingService(
                    selectionGateway: selectionGateway,
                    shareGateway: shareGateway,
                  );
                  await service.shareAyahImage(draft);
                }
              },
            ),
          ),
        );
      case AyahAction.setWirdStart:
        break;
      case AyahAction.setWirdEnd:
        break;
    }
  }

  void _saveQuickBookmark(
    BuildContext context,
    QuranPosition position,
    BookmarkRepository repository,
  ) {
    final editor = BookmarkEditorViewModel(repository: repository);
    editor.save(position: position);
  }

  void _saveBookmarkWithNote(
    BuildContext context,
    QuranPosition position,
    BookmarkRepository repository,
  ) {
    final editor = BookmarkEditorViewModel(repository: repository);
    editor.setType(BookmarkType.note);
    editor.save(position: position);
  }
}

class _QuranReaderBody extends StatelessWidget {
  const _QuranReaderBody({
    required this.viewModel,
    required this.l10n,
    required this.onAyahSelected,
  });

  final ReaderViewModel viewModel;
  final AppLocalizations l10n;
  final Future<void> Function(QuranPosition position) onAyahSelected;

  @override
  Widget build(BuildContext context) {
    final position = viewModel.state.position;
    if (position == null) return const SizedBox.shrink();

    final widgetFactory = _tryRead<QuranReaderWidgetFactory>(context);

    if (widgetFactory != null) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final style = RaqeemReaderStyle(
        isDark: isDark,
        languageCode: l10n.locale.languageCode,
      );

      final quranWidget = widgetFactory.buildFullReader(
        context: context,
        style: style,
        languageCode: l10n.locale.languageCode,
        initialPageIndex: position.page - 1,
        onPageChanged: (pageNumber) => _handlePageChange(context, pageNumber),
        onAyahSelected: (ayahUQ) async {
          final navGateway = _tryRead<QuranNavigationGateway>(context);
          if (navGateway == null) return;
          try {
            final ayahPos = await navGateway.resolveAyahPosition(ayahUQ);
            viewModel.selectAyah(ayahPos);
            if (!context.mounted) return;
            await onAyahSelected(ayahPos);
            viewModel.clearAyahSelection();
          } catch (_) {}
        },
        onPageTap: viewModel.toggleControls,
      );

      return Positioned.fill(child: quranWidget);
    }

    return _ReaderPlaceholder(position: position, l10n: l10n);
  }

  void _handlePageChange(BuildContext context, int pageIndex) {
    final gateway = _tryRead<QuranNavigationGateway>(context);
    if (gateway == null) return;
    final service = _tryRead<ReaderPositionService>(context);
    // pageIndex is 0-based from PageView; resolvePageStart expects 1-based page
    final pageNumber = pageIndex + 1;
    gateway.resolvePageStart(pageNumber).then((pos) {
      viewModel.openAtPosition(pos);
      service?.updatePosition(pos);
    });
  }
}

class _ReaderPlaceholder extends StatelessWidget {
  const _ReaderPlaceholder({required this.position, required this.l10n});

  final QuranPosition position;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              position.displaySurahName,
              style: const TextStyle(
                color: RaqeemColors.primaryText,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.pageLabel} ${position.page}',
              style: const TextStyle(
                color: RaqeemColors.secondaryText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopControlsBar extends StatelessWidget {
  const _TopControlsBar({required this.viewModel, required this.l10n});

  final ReaderViewModel viewModel;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              RaqeemColors.background,
              RaqeemColors.background.withValues(alpha: 0),
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            _ControlButton(
              buttonKey: const Key('reader_back'),
              icon: Icons.arrow_back_rounded,
              tooltip: l10n.back,
              onTap: () => Navigator.of(context).maybePop(),
            ),
            const Spacer(),
            _ControlButton(
              buttonKey: const Key('reader_navigate_surah'),
              icon: Icons.list_rounded,
              tooltip: l10n.navigateBySurah,
              onTap: () => _showNavigationSheet(context),
            ),
            _ControlButton(
              buttonKey: const Key('reader_navigate_juz'),
              icon: Icons.menu_book_rounded,
              tooltip: l10n.navigateByJuz,
              onTap: () => _showNavigationSheet(context),
            ),
            _ControlButton(
              buttonKey: const Key('reader_bookmark'),
              icon: Icons.bookmark_outline_rounded,
              tooltip: l10n.bookmarks,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  void _showNavigationSheet(BuildContext context) {
    final navigationGateway = _tryRead<QuranNavigationGateway>(context);
    if (navigationGateway == null) return;

    NavigationSelectorSheet.show(
      context,
      onNavigate: (item) async {
        switch (item.type) {
          case NavigationIndexType.surah:
            await viewModel.navigateBySurah(item.number);
          case NavigationIndexType.juz:
            await viewModel.navigateByJuz(item.number);
          case NavigationIndexType.hizb:
            await viewModel.navigateByHizb(item.number);
          case NavigationIndexType.rub:
            await viewModel.navigateByRub(item.number);
          case NavigationIndexType.page:
            await viewModel.jumpToPage(item.number);
        }
      },
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.buttonKey,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: IconButton(
        key: buttonKey,
        icon: Icon(icon, color: RaqeemColors.primaryText, size: 22),
        onPressed: onTap,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.error,
    required this.l10n,
    required this.onRetry,
  });

  final AppError? error;
  final AppLocalizations l10n;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: RaqeemColors.secondaryText,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              error?.message ?? l10n.readerError,
              style: const TextStyle(
                color: RaqeemColors.secondaryText,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _RetryButton(label: l10n.retry, onTap: onRetry),
          ],
        ),
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RaqeemColors.primary,
      borderRadius: BorderRadius.circular(RaqeemRadii.medium),
      child: InkWell(
        key: const Key('reader_retry'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(RaqeemRadii.medium),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            label,
            style: const TextStyle(
              color: RaqeemColors.softWhite,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

T? _tryRead<T>(BuildContext context) {
  try {
    return context.read<T>();
  } on ProviderNotFoundException {
    return null;
  }
}
