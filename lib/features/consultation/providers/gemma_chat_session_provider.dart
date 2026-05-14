import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../models/consultation.dart';
import '../../../models/consultation_message.dart';
import '../../../services/consultation_service.dart';

// ── 4개 언어 × 2개 분석 유형 시스템 인스트럭션 ──────────────────────────────

String buildConsultationSystemInstruction({
  required String locale,
  required AnalysisType analysisType,
  required String contextSummary,
  required Map<String, dynamic> features,
}) {
  final isface = analysisType == AnalysisType.face;
  // 핵심 수치만 간략히 포함 (raw float 전체 나열 금지 — 모델 혼란 방지)
  final keyFeatures = _formatKeyFeatures(features);

  final instructions = <String, String>{
    'ko': '''당신은 한국 전통 ${isface ? '관상' : '수상'} 전문가입니다.
아래 분석 결과를 바탕으로 사용자의 추가 질문에 답변하세요.

[분석 결과 요약]
$contextSummary

[주요 특징]
$keyFeatures

답변은 200~400자로, 한국어로 작성하세요.
단정적 표현을 피하고 가능성과 경향으로 설명하세요.''',

    'en': '''You are a ${isface ? 'face reading' : 'palm reading'} expert.
Answer the user's questions based on the analysis below.

[Analysis Summary]
$contextSummary

[Key Features]
$keyFeatures

Answer in 150-350 words in English.
Speak in tendencies and possibilities, not certainties.''',

    'zh': '''您是${isface ? '面相' : '手相'}专家。
请根据以下分析结果回答用户的问题。

[分析摘要]
$contextSummary

[主要特征]
$keyFeatures

用中文回答，200-400字。以倾向性表达，避免断言。''',

    'ja': '''あなたは${isface ? '観相' : '手相'}の専門家です。
以下の分析結果をもとに、ユーザーの質問に答えてください。

[分析サマリー]
$contextSummary

[主な特徴]
$keyFeatures

日本語で200〜400文字で答えてください。断定的な表現は避けてください。''',
  };

  return instructions[locale] ?? instructions['ko']!;
}

String _formatKeyFeatures(Map<String, dynamic> features) {
  // 읽기 좋은 한국어 레이블로 변환, 소수점 2자리로 반올림
  final labels = <String, String>{
    'eyeSpan': '눈 간격',
    'faceHeight': '얼굴 높이',
    'noseRatio': '코 위치',
    'mouthWidth': '입 너비',
    'symmetry': '좌우 대칭',
    'foreheadHeight': '이마 높이',
    'eyebrowDistance': '눈썹 간격',
  };
  return features.entries
      .where((e) => labels.containsKey(e.key))
      .map((e) {
        final label = labels[e.key]!;
        final val = e.value is double
            ? (e.value as double).toStringAsFixed(2)
            : e.value.toString();
        return '- $label: $val';
      })
      .join('\n');
}

// ── Provider (no codegen — plain Riverpod) ────────────────────────────────────

final gemmaChatSessionProvider =
    Provider<GemmaChatSessionNotifier>((ref) {
  final notifier = GemmaChatSessionNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

class GemmaChatSessionNotifier {
  GemmaChatSessionNotifier(this._ref);

  final Ref _ref;
  InferenceChat? _chat;
  String? _activeConsultationId;

  bool get hasSession => _chat != null;

  /// 화면 진입 시 호출 — 같은 세션이면 재사용, 다르면 새로 생성
  Future<void> openSession(Consultation consultation) async {
    if (_activeConsultationId == consultation.id && _chat != null) return;

    await _closeChat();

    final model = await _loadModelWithFallback();

    // GemmaService(관상/손금)와 같은 네이티브 모델을 공유하므로,
    // 이전 분석이 남긴 세션 캐시(_createCompleter)를 닫아 리셋해야
    // createChat()이 올바른 system instruction으로 새 네이티브 세션을 생성한다.
    await model.session?.close();

    _chat = await model.createChat(
      modelType: ModelType.gemmaIt,
      systemInstruction: buildConsultationSystemInstruction(
        locale: consultation.locale,
        analysisType: consultation.analysisType,
        contextSummary: consultation.contextSummary,
        features: consultation.contextFeatures,
      ),
      temperature: AppConst.gemmaTemp,
      topK: AppConst.gemmaTopK,
    );

    // DB에서 기존 메시지 로드 → sliding window → 컨텍스트 복원
    final messages = await _ref
        .read(consultationServiceProvider)
        .getMessages(consultation.id);
    final windowed = _applySlidingWindow(messages);
    for (final msg in windowed) {
      await _chat!.addQueryChunk(
        Message(text: msg.content, isUser: msg.role == MessageRole.user),
      );
    }

    _activeConsultationId = consultation.id;
    debugPrint(
        '[GemmaChatSession] 세션 시작: ${consultation.id} (${windowed.length}턴 복원)');
  }

  /// 사용자 메시지 전송 → 스트림으로 응답 토큰 방출
  Stream<String> sendMessage(String userInput) async* {
    if (_chat == null) throw StateError('Chat session not opened');

    await _chat!.addQueryChunk(Message(text: userInput, isUser: true));

    await for (final response in _chat!.generateChatResponseAsync()) {
      if (response is TextResponse) {
        yield response.token;
      }
    }
  }

  List<ConsultationMessage> _applySlidingWindow(
    List<ConsultationMessage> all, {
    int maxTurns = 12,
  }) {
    if (all.length <= maxTurns) return all;
    return all.sublist(all.length - maxTurns);
  }

  static Future<InferenceModel> _loadModelWithFallback() async {
    for (final backend in [PreferredBackend.gpu, PreferredBackend.cpu]) {
      try {
        final model = await FlutterGemma.getActiveModel(
          maxTokens: AppConst.gemmaMaxTokens,
          preferredBackend: backend,
        );
        debugPrint('[GemmaChatSession] 모델 로드 backend=$backend');
        return model;
      } catch (e) {
        debugPrint('[GemmaChatSession] $backend 백엔드 실패: $e');
      }
    }
    throw StateError('[GemmaChatSession] 모든 백엔드에서 모델 로드 실패');
  }

  Future<void> _closeChat() async {
    // chat.close()를 호출하면 FlutterGemma 모델 상태가 오염되어 다음 세션에서
    // 첫 토큰만 생성하고 멈추는 버그 발생 (GemmaService와 동일한 패턴).
    _chat = null;
    _activeConsultationId = null;
  }

  void dispose() {
    _closeChat();
  }
}
