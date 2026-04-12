import 'package:flutter_test/flutter_test.dart';
import 'package:gwansang/data/gemma/prompt_builder.dart';
import 'package:gwansang/domain/entities/landmark_result.dart';

void main() {
  group('PromptBuilder', () {
    const features = FaceFeatures(
      eyeSpan: 0.18,
      faceHeight: 0.64,
      noseRatio: 0.55,
      mouthWidth: 0.22,
      symmetry: 0.04,
      foreheadHeight: 0.13,
      eyebrowDistance: 0.05,
    );

    group('buildRealtimePrompt', () {
      test('ko 프롬프트는 한국어 키워드를 포함한다', () {
        final prompt = PromptBuilder.buildRealtimePrompt(features, 'ko');
        expect(prompt, contains('이마'));
        expect(prompt, contains('눈 간격'));
        expect(prompt, contains('2~3문장'));
      });

      test('en 프롬프트는 영어 키워드를 포함한다', () {
        final prompt = PromptBuilder.buildRealtimePrompt(features, 'en');
        expect(prompt, contains('Forehead'));
        expect(prompt, contains('Eye spacing'));
      });

      test('지원하지 않는 locale은 ko로 폴백한다', () {
        final prompt = PromptBuilder.buildRealtimePrompt(features, 'fr');
        expect(prompt, contains('이마'));
      });
    });

    group('기술어 변환', () {
      test('eyeSpan > 0.18 → 넓음', () {
        final f = features.copyWith(eyeSpan: 0.19);
        final p = PromptBuilder.buildRealtimePrompt(f, 'ko');
        expect(p, contains('넓음'));
      });

      test('eyeSpan <= 0.14 → 좁음', () {
        final f = features.copyWith(eyeSpan: 0.13);
        final p = PromptBuilder.buildRealtimePrompt(f, 'ko');
        expect(p, contains('좁음'));
      });

      test('symmetry < 0.05 → 매우 대칭', () {
        final f = features.copyWith(symmetry: 0.03);
        final p = PromptBuilder.buildRealtimePrompt(f, 'ko');
        expect(p, contains('매우 대칭'));
      });

      test('symmetry >= 0.12 → 약간 비대칭', () {
        final f = features.copyWith(symmetry: 0.15);
        final p = PromptBuilder.buildRealtimePrompt(f, 'ko');
        expect(p, contains('약간 비대칭'));
      });
    });

    group('kRealtimeSystemPrompts', () {
      test('4개 언어 모두 존재한다', () {
        expect(kRealtimeSystemPrompts.containsKey('ko'), isTrue);
        expect(kRealtimeSystemPrompts.containsKey('en'), isTrue);
        expect(kRealtimeSystemPrompts.containsKey('ja'), isTrue);
        expect(kRealtimeSystemPrompts.containsKey('zh'), isTrue);
      });

      test('ko 프롬프트는 2~3문장 제약을 명시한다', () {
        expect(kRealtimeSystemPrompts['ko'], contains('2~3문장'));
      });
    });

    group('kLongFormSystemPrompts', () {
      test('4개 언어 모두 존재한다', () {
        expect(kLongFormSystemPrompts.containsKey('ko'), isTrue);
        expect(kLongFormSystemPrompts.containsKey('en'), isTrue);
      });

      test('ko 장문 프롬프트는 6개 섹션을 명시한다', () {
        final p = kLongFormSystemPrompts['ko']!;
        expect(p, contains('이마'));
        expect(p, contains('눈'));
        expect(p, contains('코'));
        expect(p, contains('입'));
        expect(p, contains('턱'));
        expect(p, contains('종합'));
      });

      test('ko 장문 프롬프트는 1000자 이상 요구를 명시한다', () {
        expect(kLongFormSystemPrompts['ko'], contains('1000자'));
      });
    });
  });
}
