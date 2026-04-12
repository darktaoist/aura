import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gwansang/features/face_reading/camera/widgets/stability_indicator.dart';

void main() {
  Widget buildWidget({required double progress, required bool isStable}) {
    return MaterialApp(
      home: Scaffold(
        body: StabilityIndicator(progress: progress, isStable: isStable),
      ),
    );
  }

  group('StabilityIndicator', () {
    testWidgets('isStable=false 일 때 진행바를 표시한다', (tester) async {
      await tester.pumpWidget(buildWidget(progress: 0.5, isStable: false));
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('얼굴 안정화 중...'), findsOneWidget);
    });

    testWidgets('isStable=true 일 때 완료 텍스트를 표시한다', (tester) async {
      await tester.pumpWidget(buildWidget(progress: 1.0, isStable: true));
      expect(find.text('특이점 추출 완료'), findsOneWidget);
      // 진행바 숨김
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('progress=0 일 때 빈 진행바를 표시한다', (tester) async {
      await tester.pumpWidget(buildWidget(progress: 0.0, isStable: false));
      final progressBar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressBar.value, 0.0);
    });
  });
}
