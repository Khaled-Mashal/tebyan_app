import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/raqeem_theme.dart';
import '../application/bookmarks_view_model.dart';
import '../domain/bookmark_annotation.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key, this.onOpenLocation});

  final void Function(BookmarkAnnotation bookmark)? onOpenLocation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookmarks)),
      body: Consumer<BookmarksViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.status == BookmarksStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: RaqeemColors.primary),
            );
          }

          if (viewModel.status == BookmarksStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(RaqeemSpacing.large),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.bookmarksLoadError,
                      style: const TextStyle(color: RaqeemColors.primaryText),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      key: const Key('bookmarks_retry'),
                      onPressed: () {
                        viewModel.clearError();
                        viewModel.loadBookmarks();
                      },
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          if (viewModel.isEmpty) {
            return Center(
              key: const Key('bookmarks_empty'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bookmark_outline_rounded,
                    size: 48,
                    color: RaqeemColors.secondaryText.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.bookmarksEmptyTitle,
                    style: const TextStyle(
                      color: RaqeemColors.secondaryText,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            key: const Key('bookmarks_list'),
            itemCount: viewModel.bookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = viewModel.bookmarks[index];
              return _BookmarkItem(
                key: Key('bookmark_item_${bookmark.id}'),
                bookmark: bookmark,
                onOpenLocation: onOpenLocation,
                onDelete: () => viewModel.deleteBookmark(bookmark.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _BookmarkItem extends StatelessWidget {
  const _BookmarkItem({
    super.key,
    required this.bookmark,
    this.onOpenLocation,
    required this.onDelete,
  });

  final BookmarkAnnotation bookmark;
  final void Function(BookmarkAnnotation)? onOpenLocation;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => onOpenLocation?.call(bookmark),
        borderRadius: BorderRadius.circular(RaqeemRadii.medium),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 32,
                decoration: BoxDecoration(
                  color: _colorFor(bookmark.color),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${bookmark.position.displaySurahName} '
                      '${bookmark.position.ayahNumber}',
                      style: const TextStyle(
                        color: RaqeemColors.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (bookmark.note != null && bookmark.note!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          bookmark.note!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: RaqeemColors.secondaryText,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                key: Key('bookmark_delete_${bookmark.id}'),
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                onPressed: onDelete,
                tooltip: 'حذف',
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorFor(BookmarkColor color) {
    return switch (color) {
      BookmarkColor.gold => RaqeemColors.accentGold,
      BookmarkColor.green => RaqeemColors.success,
      BookmarkColor.red => RaqeemColors.error,
      BookmarkColor.blue => const Color(0xFF5B8BA0),
      BookmarkColor.neutral => RaqeemColors.secondaryText,
    };
  }
}
