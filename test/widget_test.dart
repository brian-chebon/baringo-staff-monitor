import 'package:flutter_test/flutter_test.dart';

import 'package:staff_performance_mapping/constants/baringo_data.dart';

void main() {
  group('Baringo data — administrative geography', () {
    test('every sub-county has at least one ward', () {
      for (final sc in BaringoData.subCounties) {
        final wards = BaringoData.subCountyWards[sc];
        expect(wards, isNotNull, reason: 'wards missing for $sc');
        expect(wards!, isNotEmpty, reason: 'wards empty for $sc');
      }
    });

    test('sub-county view totals exactly 30 wards', () {
      final all = BaringoData.subCountyWards.values
          .expand((wards) => wards)
          .toList();
      expect(all.length, 30, reason: 'Baringo has 30 IEBC wards');
    });

    test('IEBC constituency view also totals 30 wards across 6 constituencies',
        () {
      expect(BaringoData.constituencies.length, 6);
      final all = BaringoData.constituencyWards.values
          .expand((wards) => wards)
          .toList();
      expect(all.length, 30);
    });

    test('the same wards appear in both views (union equality)', () {
      final scWards = BaringoData.subCountyWards.values
          .expand((wards) => wards)
          .toSet();
      final ieWards = BaringoData.constituencyWards.values
          .expand((wards) => wards)
          .toSet();
      expect(
        scWards,
        ieWards,
        reason: 'Sub-county wards and constituency wards must be identical sets',
      );
    });
  });

  group('Baringo data — government structure', () {
    test('departments are non-empty and unique', () {
      expect(BaringoData.departments, isNotEmpty);
      expect(
        BaringoData.departments.toSet().length,
        BaringoData.departments.length,
      );
    });

    test('every department has a CECM listed', () {
      for (final dept in BaringoData.departments) {
        expect(
          BaringoData.cabinet.containsKey(dept),
          isTrue,
          reason: 'no CECM listed for $dept',
        );
      }
    });

    test('every department has at least one directorate', () {
      for (final dept in BaringoData.departments) {
        final dirs = BaringoData.subDepartments[dept];
        expect(dirs, isNotNull, reason: 'no directorates for $dept');
        expect(dirs!, isNotEmpty);
      }
    });

    test('legacy department aliases all map to a current department', () {
      for (final entry in BaringoData.legacyDepartmentAliases.entries) {
        expect(
          BaringoData.departments,
          contains(entry.value),
          reason: 'alias ${entry.key} → ${entry.value} is not a current dept',
        );
      }
    });
  });
}
