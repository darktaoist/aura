import 'package:flutter_test/flutter_test.dart';
import 'package:gwansang/domain/entities/landmark_result.dart';
import 'package:gwansang/domain/physiognomy/landmark_index.dart';

void main() {
  group('LandmarkIndex', () {
    test('kKeyLandmarks는 17개 항목을 포함한다', () {
      expect(kKeyLandmarks.length, 17);
    });

    test('모든 인덱스는 468 미만이다', () {
      for (final idx in kKeyLandmarks.values) {
        expect(idx, lessThan(468),
            reason: '${kKeyLandmarks.keys.firstWhere((k) => kKeyLandmarks[k] == idx)} 인덱스가 범위 초과');
      }
    });

    test('중복 인덱스가 없다', () {
      final values = kKeyLandmarks.values.toList();
      final uniqueValues = values.toSet();
      expect(values.length, uniqueValues.length, reason: '중복 인덱스 발견');
    });
  });

  group('FaceFeatures', () {
    test('copyWith는 지정 필드만 변경한다', () {
      const original = FaceFeatures(
        eyeSpan: 0.18,
        faceHeight: 0.64,
        noseRatio: 0.55,
        mouthWidth: 0.22,
        symmetry: 0.04,
        foreheadHeight: 0.13,
        eyebrowDistance: 0.05,
      );

      final modified = original.copyWith(eyeSpan: 0.25);
      expect(modified.eyeSpan, 0.25);
      expect(modified.faceHeight, original.faceHeight);
      expect(modified.symmetry, original.symmetry);
    });
  });
}
