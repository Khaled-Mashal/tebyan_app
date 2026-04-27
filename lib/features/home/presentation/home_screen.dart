import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/navigation/app_router.dart';
import '../../../app/theme/raqeem_theme.dart';
import '../../home/domain/last_reading_entry.dart';
import '../../khatma/application/active_khatma_summary.dart';
import '../../quran/domain/quran_position.dart';
import '../application/home_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, _) {
        final state = viewModel.state;
        final l10n = AppLocalizations.of(context);

        if (state.status == HomeDashboardStatus.loading) {
          return Scaffold(
            backgroundColor: RaqeemColors.background,
            body: Center(
              child: CircularProgressIndicator(
                color: RaqeemColors.primary,
                strokeWidth: 2.5,
              ),
            ),
          );
        }

        if (state.status == HomeDashboardStatus.error) {
          return _RaqeemErrorView(
            message: l10n.homeLoadError,
            onRetry: viewModel.load,
          );
        }

        return Scaffold(
          backgroundColor: RaqeemColors.background,
          body: SafeArea(
            child: RefreshIndicator(
              color: RaqeemColors.primary,
              onRefresh: viewModel.load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HomeAppBar(
                      onSettingsTap: () {
                        viewModel.openShortcut(HomeShortcut.settings);
                        _navigateToShortcut(context, HomeShortcut.settings);
                      },
                    ),
                    const SizedBox(height: 20),
                    _GreetingSection(l10n: l10n),
                    const SizedBox(height: 24),
                    if (state.latestReading != null)
                      _ContinueReadingCard(
                        entry: state.latestReading!,
                        l10n: l10n,
                        onResume: () {
                          viewModel.continueReading();
                          _navigateToReader(
                            context,
                            viewModel.state.latestReading?.position,
                          );
                        },
                      )
                    else
                      _StartReadingCard(
                        l10n: l10n,
                        onOpenReader: () {
                          viewModel.openShortcut(HomeShortcut.reader);
                          _navigateToShortcut(context, HomeShortcut.reader);
                        },
                      ),
                    if (state.activeKhatma != null) ...[
                      const SizedBox(height: 16),
                      _ActiveKhatmaCard(
                        summary: state.activeKhatma!,
                        l10n: l10n,
                        onTap: () {
                          viewModel.openShortcut(HomeShortcut.khatma);
                          _navigateToShortcut(context, HomeShortcut.khatma);
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    _ShortcutsGrid(
                      l10n: l10n,
                      onShortcut: (shortcut) {
                        viewModel.openShortcut(shortcut);
                        _navigateToShortcut(context, shortcut);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToReader(BuildContext context, QuranPosition? position) {
    if (position == null) return;
    final viewModel = context.read<HomeViewModel>();
    Navigator.of(context)
        .pushNamed(AppRouter.reader, arguments: position)
        .then((_) => viewModel.load());
  }

  void _navigateToShortcut(BuildContext context, HomeShortcut shortcut) {
    final destination = switch (shortcut) {
      HomeShortcut.reader => AppRouter.reader,
      HomeShortcut.bookmarks => AppRouter.bookmarks,
      HomeShortcut.search => AppRouter.search,
      HomeShortcut.khatma => AppRouter.khatma,
      HomeShortcut.settings => AppRouter.settings,
    };
    final viewModel = context.read<HomeViewModel>();
    Navigator.of(context).pushNamed(destination).then((_) => viewModel.load());
  }
}

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar({required this.onSettingsTap});

  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          AppLocalizations.of(context).appName,
          style: const TextStyle(
            color: RaqeemColors.primaryText,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        _RaqeemIconButton(icon: Icons.settings_outlined, onTap: onSettingsTap),
      ],
    );
  }
}

class _GreetingSection extends StatelessWidget {
  const _GreetingSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeGreeting,
          style: const TextStyle(
            color: RaqeemColors.secondaryText,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          l10n.homeGreetingBody,
          style: const TextStyle(
            color: RaqeemColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({
    required this.entry,
    required this.l10n,
    required this.onResume,
  });

  final LastReadingEntry entry;
  final AppLocalizations l10n;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final position = entry.position;

    return _RaqeemCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: RaqeemColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(RaqeemRadii.small),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: RaqeemColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.continueReading,
                style: const TextStyle(
                  color: RaqeemColors.primaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 38),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  position.displaySurahName,
                  style: const TextStyle(
                    color: RaqeemColors.primaryText,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.pageLabel} ${position.page}  •  ${l10n.ayahLabel} ${position.ayahNumber}',
                  style: const TextStyle(
                    color: RaqeemColors.secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _RaqeemFilledButton(
              label: l10n.resumeReading,
              icon: Icons.arrow_back_rounded,
              onTap: onResume,
            ),
          ),
        ],
      ),
    );
  }
}

class _StartReadingCard extends StatelessWidget {
  const _StartReadingCard({required this.l10n, required this.onOpenReader});

  final AppLocalizations l10n;
  final VoidCallback onOpenReader;

  @override
  Widget build(BuildContext context) {
    return _RaqeemCard(
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Icon(
            Icons.auto_stories_outlined,
            color: RaqeemColors.primary,
            size: 36,
          ),
          const SizedBox(height: 14),
          Text(
            l10n.emptyReadingTitle,
            style: const TextStyle(
              color: RaqeemColors.primaryText,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.emptyReadingBody,
            style: const TextStyle(
              color: RaqeemColors.secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Center(
            child: _RaqeemFilledButton(
              label: l10n.openReader,
              icon: Icons.menu_book_rounded,
              onTap: onOpenReader,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _ActiveKhatmaCard extends StatelessWidget {
  const _ActiveKhatmaCard({
    required this.summary,
    required this.l10n,
    required this.onTap,
  });

  final ActiveKhatmaSummary summary;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = summary.progress;
    final percent = (progress * 100).round();

    return _RaqeemCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: RaqeemColors.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(RaqeemRadii.small),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: RaqeemColors.accentGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  summary.planName,
                  style: const TextStyle(
                    color: RaqeemColors.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: RaqeemColors.secondaryText,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 38),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.todayWird}: ${summary.todayWirdTitle}',
                  style: const TextStyle(
                    color: RaqeemColors.secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: RaqeemColors.primary.withValues(
                            alpha: 0.12,
                          ),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            RaqeemColors.accentGold,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        color: RaqeemColors.primaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutsGrid extends StatelessWidget {
  const _ShortcutsGrid({required this.l10n, required this.onShortcut});

  final AppLocalizations l10n;
  final void Function(HomeShortcut) onShortcut;

  @override
  Widget build(BuildContext context) {
    final shortcuts = <_ShortcutItem>[
      _ShortcutItem(
        icon: Icons.menu_book_rounded,
        label: l10n.reader,
        shortcut: HomeShortcut.reader,
      ),
      _ShortcutItem(
        icon: Icons.bookmark_outline_rounded,
        label: l10n.bookmarks,
        shortcut: HomeShortcut.bookmarks,
      ),
      _ShortcutItem(
        icon: Icons.search_rounded,
        label: l10n.search,
        shortcut: HomeShortcut.search,
      ),
      _ShortcutItem(
        icon: Icons.assignment_outlined,
        label: l10n.khatma,
        shortcut: HomeShortcut.khatma,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 12),
          child: Text(
            l10n.shortcuts,
            style: const TextStyle(
              color: RaqeemColors.secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Row(
          children: shortcuts.map((item) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _ShortcutCard(
                  item: item,
                  onTap: () => onShortcut(item.shortcut),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({required this.item, required this.onTap});

  final _ShortcutItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RaqeemColors.surface,
      borderRadius: BorderRadius.circular(RaqeemRadii.medium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RaqeemRadii.medium),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(item.icon, color: RaqeemColors.secondaryText, size: 22),
        ),
      ),
    );
  }
}

class _RaqeemCard extends StatelessWidget {
  const _RaqeemCard({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RaqeemColors.surface,
        borderRadius: BorderRadius.circular(RaqeemRadii.medium),
        border: Border.all(
          color: RaqeemColors.primary.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(RaqeemRadii.medium),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RaqeemRadii.medium),
          child: body,
        ),
      );
    }

    return body;
  }
}

class _RaqeemFilledButton extends StatelessWidget {
  const _RaqeemFilledButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RaqeemColors.primary,
      borderRadius: BorderRadius.circular(RaqeemRadii.medium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RaqeemRadii.medium),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: RaqeemColors.softWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Icon(icon, color: RaqeemColors.softWhite, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _RaqeemIconButton extends StatelessWidget {
  const _RaqeemIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(RaqeemRadii.medium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RaqeemRadii.medium),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Icon(icon, color: RaqeemColors.secondaryText, size: 22),
          ),
        ),
      ),
    );
  }
}

class _RaqeemErrorView extends StatelessWidget {
  const _RaqeemErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RaqeemColors.background,
      body: Center(
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
                message,
                style: const TextStyle(
                  color: RaqeemColors.secondaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _RaqeemFilledButton(
                label: AppLocalizations.of(context).retry,
                icon: Icons.refresh_rounded,
                onTap: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutItem {
  const _ShortcutItem({
    required this.icon,
    required this.label,
    required this.shortcut,
  });

  final IconData icon;
  final String label;
  final HomeShortcut shortcut;
}
