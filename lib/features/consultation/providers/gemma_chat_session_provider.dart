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
  final featureLines =
      features.entries.map((e) => '- ${e.key}: ${e.value}').join('\n');

  final instructions = <String, String>{
    'ko': '''당신은 20년 경력의 한국 전통 ${isface ? '관상' : '수상'} 전문가입니다.
사용자가 이미 받은 ${isface ? '관상' : '수상'} 분석 결과를 바탕으로, 추가 질문에 전문적으로 답변하세요.

[분석 결과 요약]
$contextSummary

[분석된 특징 데이터]
$featureLines

[답변 원칙]
1. 항상 위 분석 결과를 근거로 답변할 것
2. ${isface ? '관상' : '수상'}·운세 외 질문은 "${isface ? '관상' : '수상'} 상담에 집중해드리고 있어요. 관련 질문을 해주시겠어요?"로 정중히 거절할 것
3. 단정적·부정적 운명 단언은 피하고, 가능성·경향·조언으로 표현할 것
4. 한 답변은 200~500자 사이로 작성할 것
5. 한국어로 답변할 것''',
    'en': '''You are a master ${isface ? 'physiognomist' : 'palm reader'} with 20 years of experience.
Answer follow-up questions based on the user's prior analysis result.

[Prior Analysis Summary]
$contextSummary

[Analyzed Features]
$featureLines

[Response Rules]
1. Ground every answer in the analysis above
2. Politely decline off-topic questions: "I'm focused on your ${isface ? 'face reading' : 'palm reading'} consultation. Could you ask about your reading?"
3. Avoid deterministic or negative fate claims; speak in tendencies and advice
4. Keep each answer between 150-400 words
5. Respond in English''',
    'zh': '''您是一位拥有20年经验的${isface ? '面相' : '手相'}专家。
请基于用户已收到的分析结果，专业地回答后续问题。

[分析结果摘要]
$contextSummary

[已分析的特征]
$featureLines

[回答规则]
1. 所有回答都必须基于上述分析结果
2. 对于无关问题，请礼貌拒绝："我正在专注于您的${isface ? '面相' : '手相'}咨询。您能问与之相关的问题吗？"
3. 避免决定性或负面的命运断言，以倾向性和建议表达
4. 每次回答保持在200-500字之间
5. 用中文回答''',
    'ja': '''あなたは20年の経験を持つ${isface ? '観相' : '手相'}の専門家です。
ユーザーが既に受け取った分析結果を基に、追加の質問に専門的にお答えください。

[分析結果の要約]
$contextSummary

[分析された特徴]
$featureLines

[回答ルール]
1. すべての回答を上記の分析結果に基づかせること
2. 無関係な質問は丁寧に断ること：「${isface ? '観相' : '手相'}相談に集中しております。関連する質問をお願いできますか？」
3. 断定的・否定的な運命の断言は避け、傾向と助言として表現すること
4. 一回の回答は200〜500文字に収めること
5. 日本語で回答すること''',
  };

  return instructions[locale] ?? instructions['ko']!;
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

    final model = await FlutterGemma.getActiveModel(
      maxTokens: AppConst.gemmaMaxTokens,
    );

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

  Future<void> _closeChat() async {
    try {
      await _chat?.close();
    } catch (e) {
      debugPrint('[GemmaChatSession] chat.close() error (ignored): $e');
    }
    _chat = null;
    _activeConsultationId = null;
  }

  void dispose() {
    _closeChat();
  }
}
