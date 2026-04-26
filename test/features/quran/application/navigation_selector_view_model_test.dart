import 'package:flutter_test/flutter_test.dart';
import 'package:tebyan_app/features/quran/application/navigation_selector_view_model.dart';
import 'package:tebyan_app/features/quran/domain/quran_position.dart';
import '../../../shared/fakes/fake_quran_gateway.dart';

void main() {
  group('NavigationSelectorViewModel', () {
    late FakeQuranGateway gateway;
    late NavigationSelectorViewModel viewModel;

    setUp(() {
      gateway = FakeQuranGateway(positions: _navPositions);
      viewModel = NavigationSelectorViewModel(navigationGateway: gateway);
    });

    group('supported index types', () {
      test('default selected type is surah', () {
        expect(viewModel.selectedType, NavigationIndexType.surah);
      });

      test('surah list contains 114 items', () {
        viewModel.selectIndexType(NavigationIndexType.surah);
        expect(viewModel.allItems, hasLength(114));
      });

      test('juz list contains 30 items', () {
        viewModel.selectIndexType(NavigationIndexType.juz);
        expect(viewModel.allItems, hasLength(30));
      });

      test('hizb list contains 60 items', () {
        viewModel.selectIndexType(NavigationIndexType.hizb);
        expect(viewModel.allItems, hasLength(60));
      });

      test('rub list contains 240 items', () {
        viewModel.selectIndexType(NavigationIndexType.rub);
        expect(viewModel.allItems, hasLength(240));
      });

      test('page list contains 604 items', () {
        viewModel.selectIndexType(NavigationIndexType.page);
        expect(viewModel.allItems, hasLength(604));
      });

      test('selecting a new type resets the filter', () {
        viewModel.updateFilter('البقرة');
        expect(viewModel.filterQuery, 'البقرة');

        viewModel.selectIndexType(NavigationIndexType.juz);

        expect(viewModel.filterQuery, isEmpty);
      });

      test('items carry the correct type label', () {
        viewModel.selectIndexType(NavigationIndexType.juz);
        final items = viewModel.allItems;

        expect(items.first.type, NavigationIndexType.juz);
        expect(items.first.number, 1);
        expect(items.first.label, contains('الجزء'));
      });
    });

    group('quick search filtering', () {
      test('empty filter returns all items', () {
        viewModel.selectIndexType(NavigationIndexType.surah);
        viewModel.updateFilter('');

        expect(viewModel.filteredItems, hasLength(114));
      });

      test('filter narrows surah items by label match', () {
        viewModel.selectIndexType(NavigationIndexType.surah);
        viewModel.updateFilter('سورة 11');

        final filtered = viewModel.filteredItems;
        expect(filtered, isNotEmpty);
        for (final item in filtered) {
          expect(item.label, contains('سورة 11'));
        }
      });

      test('filter narrows juz items by label match', () {
        viewModel.selectIndexType(NavigationIndexType.juz);
        viewModel.updateFilter('الجزء 30');

        final filtered = viewModel.filteredItems;
        expect(filtered, hasLength(1));
        expect(filtered.single.number, 30);
      });

      test('filter narrows page items by exact page number', () {
        viewModel.selectIndexType(NavigationIndexType.page);
        viewModel.updateFilter('صفحة 55');

        final filtered = viewModel.filteredItems;
        expect(filtered.every((i) => i.label.contains('صفحة 55')), isTrue);
      });

      test('no match returns empty list', () {
        viewModel.selectIndexType(NavigationIndexType.surah);
        viewModel.updateFilter('لا توجد سورة بهذا الاسم');

        expect(viewModel.filteredItems, isEmpty);
      });

      test('filter is case-sensitive substring match', () {
        viewModel.selectIndexType(NavigationIndexType.juz);
        viewModel.updateFilter('الجزء 30');

        final filtered = viewModel.filteredItems;
        expect(filtered, hasLength(1));
        expect(filtered.single.number, 30);
      });
    });

    group('navigateToItem', () {
      test('surah item delegates jump to gateway', () async {
        final item = NavigationItem(
          type: NavigationIndexType.surah,
          number: 1,
          label: 'سورة 1',
        );

        await viewModel.navigateToItem(item);

        expect(gateway.jumps, hasLength(1));
      });

      test('juz item delegates jump to gateway', () async {
        final item = NavigationItem(
          type: NavigationIndexType.juz,
          number: 1,
          label: 'الجزء 1',
        );

        await viewModel.navigateToItem(item);

        expect(gateway.jumps, hasLength(1));
      });

      test('hizb item delegates jump to gateway', () async {
        final item = NavigationItem(
          type: NavigationIndexType.hizb,
          number: 1,
          label: 'الحزب 1',
        );

        await viewModel.navigateToItem(item);

        expect(gateway.jumps, hasLength(1));
      });

      test('rub item delegates jump to gateway via page', () async {
        final item = NavigationItem(
          type: NavigationIndexType.rub,
          number: 1,
          label: 'الربع 1',
        );

        await viewModel.navigateToItem(item);

        expect(gateway.jumps, hasLength(1));
      });

      test('page item delegates jump to gateway', () async {
        final item = NavigationItem(
          type: NavigationIndexType.page,
          number: 1,
          label: 'صفحة 1',
        );

        await viewModel.navigateToItem(item);

        expect(gateway.jumps, hasLength(1));
      });
    });
  });
}

final _navPositions = <QuranPosition>[
  QuranPosition(
    surahNumber: 1,
    ayahNumber: 1,
    ayahUniqueNumber: 1,
    page: 1,
    juz: 1,
    hizb: 1,
    rub: 1,
    displaySurahName: 'الفاتحة',
    displayAyahLabel: 'الفاتحة ١',
  ),
  QuranPosition(
    surahNumber: 2,
    ayahNumber: 1,
    ayahUniqueNumber: 142,
    page: 2,
    juz: 1,
    hizb: 1,
    rub: 2,
    displaySurahName: 'البقرة',
    displayAyahLabel: 'البقرة ١',
  ),
  QuranPosition(
    surahNumber: 114,
    ayahNumber: 1,
    ayahUniqueNumber: 6236,
    page: 604,
    juz: 30,
    hizb: 60,
    rub: 240,
    displaySurahName: 'الناس',
    displayAyahLabel: 'الناس ١',
  ),
];
