import 'package:alu_bridge/features/applications/data/match_score.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculateMatchScore', () {
    test('returns 0 when the role requires no skills', () {
      expect(calculateMatchScore([], ['Flutter']), 0);
    });

    test('returns 0 when there is no overlap', () {
      expect(calculateMatchScore(['Marketing'], ['Flutter', 'Dart']), 0);
    });

    test('returns 100 when every required skill is owned', () {
      expect(
        calculateMatchScore(['Flutter', 'Dart'], ['Flutter', 'Dart', 'Figma']),
        100,
      );
    });

    test('returns the rounded percentage for a partial overlap', () {
      expect(
        calculateMatchScore(['Flutter', 'Dart', 'Figma'], ['Flutter', 'Dart']),
        67,
      );
    });

    test('is case-insensitive and trims whitespace', () {
      expect(calculateMatchScore([' Flutter '], ['flutter']), 100);
    });
  });
}
