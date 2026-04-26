import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/raqeem_theme.dart';
import '../application/navigation_selector_view_model.dart';

class NavigationSelectorSheet extends StatelessWidget {
  const NavigationSelectorSheet({super.key, required this.onNavigate});

  final Future<void> Function(NavigationItem item) onNavigate;

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function(NavigationItem item) onNavigate,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: RaqeemColors.softWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) =>
            NavigationSelectorSheet(onNavigate: onNavigate),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          NavigationSelectorViewModel(navigationGateway: context.read()),
      child: _NavigationSelectorContent(onNavigate: onNavigate),
    );
  }
}

class _NavigationSelectorContent extends StatefulWidget {
  const _NavigationSelectorContent({required this.onNavigate});

  final Future<void> Function(NavigationItem item) onNavigate;

  @override
  State<_NavigationSelectorContent> createState() =>
      _NavigationSelectorContentState();
}

class _NavigationSelectorContentState
    extends State<_NavigationSelectorContent> {
  late TextEditingController _filterController;

  @override
  void initState() {
    super.initState();
    _filterController = TextEditingController();
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = context.watch<NavigationSelectorViewModel>();
    final items = viewModel.filteredItems;

    return Column(
      children: [
        _SheetHandle(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Text(
                l10n.selectIndexType,
                style: const TextStyle(
                  color: RaqeemColors.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
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
        const SizedBox(height: 12),
        _IndexTypeTabs(viewModel: viewModel, l10n: l10n),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _filterController,
            decoration: InputDecoration(
              hintText: l10n.filterHint,
              hintStyle: const TextStyle(
                color: RaqeemColors.secondaryText,
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: RaqeemColors.secondaryText,
                size: 20,
              ),
              filled: true,
              fillColor: RaqeemColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RaqeemRadii.medium),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              isDense: true,
            ),
            style: const TextStyle(
              color: RaqeemColors.primaryText,
              fontSize: 14,
            ),
            onChanged: viewModel.updateFilter,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    l10n.noResultsFound,
                    style: const TextStyle(
                      color: RaqeemColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    mainAxisExtent: 48,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final item = items[index];
                    return _NavigationItemTile(
                      item: item,
                      onTap: () async {
                        await widget.onNavigate(item);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class _IndexTypeTabs extends StatelessWidget {
  const _IndexTypeTabs({required this.viewModel, required this.l10n});

  final NavigationSelectorViewModel viewModel;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final tabs = <(_TabData, NavigationIndexType)>[
      (
        _TabData(label: l10n.surahLabel, icon: Icons.menu_book_outlined),
        NavigationIndexType.surah,
      ),
      (
        _TabData(label: l10n.juzLabel, icon: Icons.auto_stories_outlined),
        NavigationIndexType.juz,
      ),
      (
        _TabData(
          label: l10n.hizbLabel,
          icon: Icons.chrome_reader_mode_outlined,
        ),
        NavigationIndexType.hizb,
      ),
      (
        _TabData(label: l10n.rubLabel, icon: Icons.bookmark_outline_rounded),
        NavigationIndexType.rub,
      ),
      (
        _TabData(label: l10n.pageLabelShort, icon: Icons.description_outlined),
        NavigationIndexType.page,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: tabs.map((entry) {
          final data = entry.$1;
          final type = entry.$2;
          final isSelected = viewModel.selectedType == type;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: _IndexChip(
              label: data.label,
              icon: data.icon,
              isSelected: isSelected,
              onTap: () => viewModel.selectIndexType(type),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _IndexChip extends StatelessWidget {
  const _IndexChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? RaqeemColors.primary : RaqeemColors.surface,
      borderRadius: BorderRadius.circular(RaqeemRadii.medium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RaqeemRadii.medium),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? RaqeemColors.softWhite
                    : RaqeemColors.secondaryText,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? RaqeemColors.softWhite
                      : RaqeemColors.primaryText,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItemTile extends StatelessWidget {
  const _NavigationItemTile({required this.item, required this.onTap});

  final NavigationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RaqeemColors.surface,
      borderRadius: BorderRadius.circular(RaqeemRadii.small),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RaqeemRadii.small),
        child: Center(
          child: Text(
            item.label,
            style: const TextStyle(
              color: RaqeemColors.primaryText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _TabData {
  const _TabData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
