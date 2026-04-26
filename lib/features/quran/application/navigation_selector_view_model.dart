import 'package:flutter/foundation.dart';

import '../infrastructure/quran_gateway.dart';

enum NavigationIndexType { surah, juz, hizb, rub, page }

@immutable
class NavigationItem {
  const NavigationItem({
    required this.type,
    required this.number,
    required this.label,
  });

  final NavigationIndexType type;
  final int number;
  final String label;

  @override
  bool operator ==(Object other) =>
      other is NavigationItem && other.type == type && other.number == number;

  @override
  int get hashCode => Object.hash(type, number);
}

class NavigationSelectorViewModel extends ChangeNotifier {
  NavigationSelectorViewModel({
    required QuranNavigationGateway navigationGateway,
  }) : _navigationGateway = navigationGateway;

  final QuranNavigationGateway _navigationGateway;

  NavigationIndexType _selectedType = NavigationIndexType.surah;
  String _filterQuery = '';

  static const Map<NavigationIndexType, int> itemCounts = {
    NavigationIndexType.surah: 114,
    NavigationIndexType.juz: 30,
    NavigationIndexType.hizb: 60,
    NavigationIndexType.rub: 240,
    NavigationIndexType.page: 604,
  };

  NavigationIndexType get selectedType => _selectedType;
  String get filterQuery => _filterQuery;

  List<NavigationItem> get allItems => _buildItems(_selectedType);

  List<NavigationItem> get filteredItems {
    final items = allItems;
    if (_filterQuery.isEmpty) return items;
    return items
        .where((item) => item.label.contains(_filterQuery))
        .toList(growable: false);
  }

  void selectIndexType(NavigationIndexType type) {
    _selectedType = type;
    _filterQuery = '';
    notifyListeners();
  }

  void updateFilter(String query) {
    _filterQuery = query;
    notifyListeners();
  }

  Future<void> navigateToItem(NavigationItem item) async {
    switch (item.type) {
      case NavigationIndexType.surah:
        _navigationGateway.jumpToSurah(item.number);
      case NavigationIndexType.juz:
        _navigationGateway.jumpToJuz(item.number);
      case NavigationIndexType.hizb:
        _navigationGateway.jumpToHizb(item.number);
      case NavigationIndexType.rub:
      case NavigationIndexType.page:
        _navigationGateway.jumpToPage(item.number);
    }
  }

  List<NavigationItem> _buildItems(NavigationIndexType type) {
    final count = itemCounts[type]!;
    return List.generate(count, (i) {
      final number = i + 1;
      return NavigationItem(
        type: type,
        number: number,
        label: _labelFor(type, number),
      );
    });
  }

  String _labelFor(NavigationIndexType type, int number) {
    return switch (type) {
      NavigationIndexType.surah => 'سورة $number',
      NavigationIndexType.juz => 'الجزء $number',
      NavigationIndexType.hizb => 'الحزب $number',
      NavigationIndexType.rub => 'الربع $number',
      NavigationIndexType.page => 'صفحة $number',
    };
  }
}
