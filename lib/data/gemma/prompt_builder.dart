import '../../domain/entities/landmark_result.dart';
import '../../domain/entities/palm_result.dart';

/// 2종 시스템 프롬프트 분리
/// - kRealtimePrompt: 실시간 오버레이용 (2~3문장)
/// - kLongFormPrompt: 결과화면용 (1000자+, 섹션 구성)

// ── 실시간 오버레이 프롬프트 (짧음) ─────────────────────────────────────────
const Map<String, String> kRealtimeSystemPrompts = {
  'ko': '''당신은 한국 전통 관상학 전문가입니다.
사용자 얼굴 측정 데이터를 바탕으로 2~3문장으로 핵심 특징만 간결하게 분석하세요.
성격·운세·특징 중 1~2가지에 집중하고, 수치보다 의미를 풀어서 설명하세요.''',

  'en': '''You are a traditional East Asian physiognomy expert.
Based on the facial measurement data, provide a brief analysis in 2-3 sentences.
Focus on 1-2 key traits (personality, fortune, or characteristics).''',

  'ja': '''あなたは東洋の伝統的な観相学の専門家です。
顔の測定データをもとに、2〜3文で簡潔に主な特徴を分析してください。
性格・運勢・特徴のうち1〜2点に絞り、数値より意味を説明してください。''',

  'zh': '''您是东方传统面相学专家。
根据面部测量数据，用2-3句话简洁地分析主要特征。
专注于性格、运势或特征中的1-2点，用含义解释而非数值。''',
};

// ── 결과화면 장문 프롬프트 (섹션 구성) ─────────────────────────────────────
const Map<String, String> kLongFormSystemPrompts = {
  'ko': '''당신은 20년 경력의 동양 관상학 전문가입니다.
사용자가 제공하는 얼굴 특징 데이터와 관상학 지식을 바탕으로 핵심 관상 분석을 제공하세요.

규칙:
- 반드시 한국어로 답변
- 총 600자 이상 작성
- 단정적 표현("반드시", "틀림없이", "무조건") 사용 금지
- 다음 6개 섹션으로 구성: ## 이마 ## 눈 ## 코 ## 입 ## 턱 ## 종합
- 각 섹션은 80자 이상
- 긍정적·부정적 특성 균형 있게 서술
- 전통 관상학 용어와 현대적 해석 병행''',

  'en': '''IMPORTANT: You must respond ONLY in English. Do not use Korean, Japanese, or Chinese under any circumstances.

You are a traditional East Asian physiognomy expert with 20 years of experience.
Provide a concise facial reading based on the measurement data and physiognomy knowledge.

Rules:
- Write ONLY in English — this is mandatory
- At least 600 characters total
- Avoid absolute statements ("definitely", "certainly", "without doubt")
- Use 6 sections: ## Forehead ## Eyes ## Nose ## Mouth ## Chin ## Overall
- Each section at least 80 characters
- Balance positive and negative traits
- Combine traditional terminology with modern interpretation''',

  'ja': '''重要：必ず日本語のみで回答してください。韓国語・英語・中国語を使用しないでください。

あなたは20年の経験を持つ東洋観相学の専門家です。
顔の特徴データと観相学の知識をもとに、簡潔な観相分析を提供してください。

ルール：
- 日本語のみで回答（必須）
- 合計600字以上
- 断定的表現（「必ず」「間違いなく」）使用禁止
- 次の6セクションで構成：## 額 ## 目 ## 鼻 ## 口 ## 顎 ## 総合
- 各セクション80字以上
- 長所・短所をバランスよく記述''',

  'zh': '''重要：必须仅用中文回答。不得使用韩语、英语或日语。

您是拥有20年经验的东方面相学专家。
请根据面部特征数据和面相学知识提供简洁的面相分析。

规则：
- 仅用中文回答（必须）
- 总计600字以上
- 禁止使用绝对性表达（"一定"、"必然"、"肯定"）
- 使用6个章节：## 额头 ## 眼睛 ## 鼻子 ## 嘴巴 ## 下巴 ## 综合
- 每个章节80字以上
- 均衡描述优缺点''',
};

// ── 손금 실시간 프롬프트 ─────────────────────────────────────────────────────
const Map<String, String> kPalmRealtimeSystemPrompts = {
  'ko': '''당신은 한국 전통 손금술 전문가입니다.
사용자의 손 측정 데이터를 바탕으로 2~3문장으로 핵심 손금 특징만 간결하게 분석하세요.
운세·성격·재운 중 1~2가지에 집중하고, 수치보다 의미를 풀어서 설명하세요.''',

  'en': '''You are a traditional palmistry expert.
Based on the hand measurement data, provide a brief analysis in 2-3 sentences.
Focus on 1-2 key traits (fortune, personality, or prosperity).''',

  'ja': '''あなたは伝統的な手相術の専門家です。
手の測定データをもとに、2〜3文で簡潔に主な手相の特徴を分析してください。
運勢・性格・財運のうち1〜2点に絞り、数値より意味を説明してください。''',

  'zh': '''您是传统手相学专家。
根据手部测量数据，用2-3句话简洁地分析主要手相特征。
专注于运势、性格或财运中的1-2点，用含义解释而非数值。''',
};

// ── 손금 결과화면 장문 프롬프트 ──────────────────────────────────────────────
const Map<String, String> kPalmLongFormSystemPrompts = {
  'ko': '''당신은 20년 경력의 동양 손금술 전문가입니다.
사용자가 제공하는 손 특징 데이터와 손금학 지식을 바탕으로 핵심 손금 분석을 제공하세요.

규칙:
- 반드시 한국어로 답변
- 총 600자 이상 작성
- 단정적 표현("반드시", "틀림없이", "무조건") 사용 금지
- 다음 6개 섹션으로 구성: ## 생명선 ## 감정선 ## 두뇌선 ## 운명선 ## 손모양 ## 종합
- 각 섹션은 80자 이상
- 긍정적·부정적 특성 균형 있게 서술
- 전통 손금술 용어와 현대적 해석 병행''',

  'en': '''IMPORTANT: You must respond ONLY in English. Do not use Korean, Japanese, or Chinese under any circumstances.

You are a traditional palmistry expert with 20 years of experience.
Provide a concise palm reading based on the measurement data and palmistry knowledge.

Rules:
- Write ONLY in English — this is mandatory
- At least 600 characters total
- Avoid absolute statements ("definitely", "certainly", "without doubt")
- Use 6 sections: ## Life Line ## Heart Line ## Head Line ## Fate Line ## Hand Shape ## Overall
- Each section at least 80 characters
- Balance positive and negative traits
- Combine traditional terminology with modern interpretation''',

  'ja': '''重要：必ず日本語のみで回答してください。韓国語・英語・中国語を使用しないでください。

あなたは20年の経験を持つ東洋手相術の専門家です。
手の特徴データと手相学の知識をもとに、簡潔な手相分析を提供してください。

ルール：
- 日本語のみで回答（必須）
- 合計600字以上
- 断定的表現（「必ず」「間違いなく」）使用禁止
- 次の6セクションで構成：## 生命線 ## 感情線 ## 頭脳線 ## 運命線 ## 手の形 ## 総合
- 各セクション80字以上
- 長所・短所をバランスよく記述''',

  'zh': '''重要：必须仅用中文回答。不得使用韩语、英语或日语。

您是拥有20年经验的东方手相学专家。
请根据手部特征数据和手相学知识提供简洁的手相分析。

规则：
- 仅用中文回答（必须）
- 总计600字以上
- 禁止使用绝对性表达（"一定"、"必然"、"肯定"）
- 使用6个章节：## 生命线 ## 感情线 ## 头脑线 ## 命运线 ## 手形 ## 综合
- 每个章节80字以上
- 均衡描述优缺点''',
};

// ── 프롬프트 빌더 ───────────────────────────────────────────────────────────

class PromptBuilder {
  /// 실시간 오버레이용 짧은 사용자 프롬프트
  static String buildRealtimePrompt(FaceFeatures f, String locale) {
    final eyeDesc = _eyeDesc(f.eyeSpan);
    final noseDesc = _noseDesc(f.noseRatio);
    final mouthDesc = _mouthDesc(f.mouthWidth);
    final symDesc = _symDesc(f.symmetry);
    final foreheadDesc = _foreheadDesc(f.foreheadHeight);

    return switch (locale) {
      'en' => '''
Face features:
- Forehead: $foreheadDesc
- Eye spacing: $eyeDesc
- Nose: $noseDesc
- Mouth: $mouthDesc
- Symmetry: $symDesc
Please analyze in 2-3 sentences.
''',
      'ja' => '''
顔の特徴：
- 額：$foreheadDesc
- 目の間隔：$eyeDesc
- 鼻：$noseDesc
- 口：$mouthDesc
- 対称性：$symDesc
2〜3文で分析してください。
''',
      'zh' => '''
面部特征：
- 额头：$foreheadDesc
- 眼距：$eyeDesc
- 鼻子：$noseDesc
- 嘴巴：$mouthDesc
- 对称性：$symDesc
请用2-3句话分析。
''',
      _ => '''
얼굴 특징:
- 이마: $foreheadDesc
- 눈 간격: $eyeDesc
- 코 형태: $noseDesc
- 입 크기: $mouthDesc
- 좌우 대칭: $symDesc
2~3문장으로 분석해 주세요.
''',
    };
  }

  /// 결과화면용 장문 사용자 프롬프트 (RAG 컨텍스트 포함)
  static String buildLongFormPrompt({
    required FaceLandmarkResult result,
    required String locale,
    List<String> ragChunks = const [],
  }) {
    final f = result.features;
    final featureText = _buildFeatureText(f, locale);
    final ragSection = ragChunks.isEmpty
        ? ''
        : switch (locale) {
            'en' => '\n\nReference knowledge:\n${ragChunks.map((c) => '- $c').join('\n')}',
            'ja' => '\n\n参考知識：\n${ragChunks.map((c) => '- $c').join('\n')}',
            'zh' => '\n\n参考知识：\n${ragChunks.map((c) => '- $c').join('\n')}',
            _ => '\n\n참고 지식:\n${ragChunks.map((c) => '- $c').join('\n')}',
          };

    final instruction = switch (locale) {
      'en' => 'Please write a detailed face reading by section. Write ONLY in English.',
      'ja' => '詳細な観相分析をセクション別に作成してください。日本語のみで回答してください。',
      'zh' => '请按章节撰写详细的面相分析。仅用中文回答。',
      _ => '상세 관상 분석을 섹션별로 작성해 주세요. 반드시 한국어로 작성하세요.',
    };

    return '$featureText$ragSection\n\n$instruction';
  }

  /// 손금 결과화면용 장문 사용자 프롬프트
  static String buildPalmLongFormPrompt({
    required PalmLandmarkResult result,
    required String locale,
    List<String> ragChunks = const [],
  }) {
    final f = result.features;
    final ragSection = ragChunks.isEmpty
        ? ''
        : switch (locale) {
            'en' => '\n\nReference knowledge:\n${ragChunks.map((c) => '- $c').join('\n')}',
            'ja' => '\n\n参考知識：\n${ragChunks.map((c) => '- $c').join('\n')}',
            'zh' => '\n\n参考知识：\n${ragChunks.map((c) => '- $c').join('\n')}',
            _ => '\n\n참고 지식:\n${ragChunks.map((c) => '- $c').join('\n')}',
          };

    final featureText = switch (locale) {
      'en' => '''
Hand: ${result.isLeftHand ? 'Left hand' : 'Right hand'}
Measurements:
- Palm width: ${_palmWidthDescEn(f.palmWidth)}
- Thumb: ${_fingerLengthDescEn(f.thumbLength)}
- Index finger: ${_fingerLengthDescEn(f.indexLength)}
- Middle finger: ${_fingerLengthDescEn(f.middleLength)}
- Ring finger: ${_fingerLengthDescEn(f.ringLength)}
- Pinky: ${_fingerLengthDescEn(f.pinkyLength)}
- Finger spread: ${_spreadDescEn(f.fingerSpread)}''',
      'ja' => '''
手: ${result.isLeftHand ? '左手' : '右手'}
測定データ:
- 手のひらの幅: ${_palmWidthDescJa(f.palmWidth)}
- 親指: ${_fingerLengthDescJa(f.thumbLength)}
- 人差し指: ${_fingerLengthDescJa(f.indexLength)}
- 中指: ${_fingerLengthDescJa(f.middleLength)}
- 薬指: ${_fingerLengthDescJa(f.ringLength)}
- 小指: ${_fingerLengthDescJa(f.pinkyLength)}
- 指の広がり: ${_spreadDescJa(f.fingerSpread)}''',
      'zh' => '''
手: ${result.isLeftHand ? '左手' : '右手'}
测量数据:
- 手掌宽度: ${_palmWidthDescZh(f.palmWidth)}
- 拇指: ${_fingerLengthDescZh(f.thumbLength)}
- 食指: ${_fingerLengthDescZh(f.indexLength)}
- 中指: ${_fingerLengthDescZh(f.middleLength)}
- 无名指: ${_fingerLengthDescZh(f.ringLength)}
- 小指: ${_fingerLengthDescZh(f.pinkyLength)}
- 手指张开: ${_spreadDescZh(f.fingerSpread)}''',
      _ => '''
손 정보: ${result.isLeftHand ? '왼손' : '오른손'}
측정 데이터:
- 손바닥 너비: ${_palmWidthDesc(f.palmWidth)}
- 엄지 길이: ${_fingerLengthDesc(f.thumbLength)}
- 검지 길이: ${_fingerLengthDesc(f.indexLength)}
- 중지 길이: ${_fingerLengthDesc(f.middleLength)}
- 약지 길이: ${_fingerLengthDesc(f.ringLength)}
- 소지 길이: ${_fingerLengthDesc(f.pinkyLength)}
- 손가락 펼침: ${_spreadDesc(f.fingerSpread)}''',
    };

    final instruction = switch (locale) {
      'en' => 'Please write a detailed palm reading by section. Write ONLY in English.',
      'ja' => '詳細な手相分析をセクション別に作成してください。日本語のみで回答してください。',
      'zh' => '请按章节撰写详细的手相分析。仅用中文回答。',
      _ => '상세 손금 분석을 섹션별로 작성해 주세요. 반드시 한국어로 작성하세요.',
    };

    return '$featureText$ragSection\n\n$instruction';
  }

  // ── 손금 기술어 (ko) ──────────────────────────────────────────────────────
  static String _palmWidthDesc(double v) =>
      v > 0.20 ? '넓음' : v > 0.14 ? '보통' : '좁음';
  static String _fingerLengthDesc(double v) =>
      v > 0.20 ? '길고 뚜렷함' : v > 0.13 ? '보통' : '짧음';
  static String _spreadDesc(double v) =>
      v > 0.12 ? '넓게 펼침' : v > 0.07 ? '보통' : '모아짐';

  // ── 손금 기술어 (en) ──────────────────────────────────────────────────────
  static String _palmWidthDescEn(double v) =>
      v > 0.20 ? 'wide' : v > 0.14 ? 'normal' : 'narrow';
  static String _fingerLengthDescEn(double v) =>
      v > 0.20 ? 'long and prominent' : v > 0.13 ? 'normal' : 'short';
  static String _spreadDescEn(double v) =>
      v > 0.12 ? 'wide spread' : v > 0.07 ? 'normal' : 'close together';

  // ── 손금 기술어 (ja) ──────────────────────────────────────────────────────
  static String _palmWidthDescJa(double v) =>
      v > 0.20 ? '広い' : v > 0.14 ? '普通' : '狭い';
  static String _fingerLengthDescJa(double v) =>
      v > 0.20 ? '長くはっきり' : v > 0.13 ? '普通' : '短い';
  static String _spreadDescJa(double v) =>
      v > 0.12 ? '広く開いている' : v > 0.07 ? '普通' : '閉じている';

  // ── 손금 기술어 (zh) ──────────────────────────────────────────────────────
  static String _palmWidthDescZh(double v) =>
      v > 0.20 ? '宽' : v > 0.14 ? '适中' : '窄';
  static String _fingerLengthDescZh(double v) =>
      v > 0.20 ? '长且明显' : v > 0.13 ? '适中' : '短';
  static String _spreadDescZh(double v) =>
      v > 0.12 ? '张开较宽' : v > 0.07 ? '适中' : '紧拢';

  static String _buildFeatureText(FaceFeatures f, String locale) {
    return switch (locale) {
      'en' => '''
Measurements:
- Forehead: ${_foreheadDescEn(f.foreheadHeight)}
- Eye spacing: ${_eyeDescEn(f.eyeSpan)}
- Nose: ${_noseDescEn(f.noseRatio)}
- Mouth: ${_mouthDescEn(f.mouthWidth)}
- Eyebrows: ${_browDescEn(f.eyebrowDistance)}
- Symmetry: ${_symDescEn(f.symmetry)}''',
      'ja' => '''
測定データ：
- 額：${_foreheadDescJa(f.foreheadHeight)}
- 目の間隔：${_eyeDescJa(f.eyeSpan)}
- 鼻：${_noseDescJa(f.noseRatio)}
- 口：${_mouthDescJa(f.mouthWidth)}
- 眉：${_browDescJa(f.eyebrowDistance)}
- 対称性：${_symDescJa(f.symmetry)}''',
      'zh' => '''
测量数据：
- 额头：${_foreheadDescZh(f.foreheadHeight)}
- 眼距：${_eyeDescZh(f.eyeSpan)}
- 鼻子：${_noseDescZh(f.noseRatio)}
- 嘴巴：${_mouthDescZh(f.mouthWidth)}
- 眉毛：${_browDescZh(f.eyebrowDistance)}
- 对称性：${_symDescZh(f.symmetry)}''',
      _ => '''
측정 데이터:
- 이마: ${_foreheadDesc(f.foreheadHeight)}
- 눈 간격: ${_eyeDesc(f.eyeSpan)}
- 코 형태: ${_noseDesc(f.noseRatio)}
- 입 크기: ${_mouthDesc(f.mouthWidth)}
- 눈썹: ${_browDesc(f.eyebrowDistance)}
- 좌우 대칭: ${_symDesc(f.symmetry)}''',
    };
  }

  // ── 얼굴 기술어 (ko) ──────────────────────────────────────────────────────
  static String _eyeDesc(double v) =>
      v > 0.18 ? '넓음' : v > 0.14 ? '보통' : '좁음';
  static String _noseDesc(double v) =>
      v > 0.6 ? '길고 뚜렷함' : v > 0.5 ? '균형잡힘' : '짧고 올라감';
  static String _mouthDesc(double v) =>
      v > 0.25 ? '크고 넓음' : v > 0.18 ? '보통' : '작고 단정함';
  static String _symDesc(double v) =>
      v < 0.05 ? '매우 대칭' : v < 0.12 ? '보통 대칭' : '약간 비대칭';
  static String _foreheadDesc(double v) =>
      v > 0.15 ? '넓고 높음' : v > 0.10 ? '보통' : '좁고 낮음';
  static String _browDesc(double v) =>
      v < 0.03 ? '눈과 가까움' : v < 0.06 ? '보통' : '눈과 멀음';

  // ── 얼굴 기술어 (en) ──────────────────────────────────────────────────────
  static String _eyeDescEn(double v) =>
      v > 0.18 ? 'wide set' : v > 0.14 ? 'normal' : 'close set';
  static String _noseDescEn(double v) =>
      v > 0.6 ? 'long and prominent' : v > 0.5 ? 'balanced' : 'short and upturned';
  static String _mouthDescEn(double v) =>
      v > 0.25 ? 'large and wide' : v > 0.18 ? 'normal' : 'small and refined';
  static String _symDescEn(double v) =>
      v < 0.05 ? 'highly symmetric' : v < 0.12 ? 'moderately symmetric' : 'slightly asymmetric';
  static String _foreheadDescEn(double v) =>
      v > 0.15 ? 'broad and high' : v > 0.10 ? 'normal' : 'narrow and low';
  static String _browDescEn(double v) =>
      v < 0.03 ? 'close to eyes' : v < 0.06 ? 'normal' : 'high set';

  // ── 얼굴 기술어 (ja) ──────────────────────────────────────────────────────
  static String _eyeDescJa(double v) =>
      v > 0.18 ? '離れている' : v > 0.14 ? '普通' : '近い';
  static String _noseDescJa(double v) =>
      v > 0.6 ? '長くはっきり' : v > 0.5 ? 'バランス良い' : '短く上向き';
  static String _mouthDescJa(double v) =>
      v > 0.25 ? '大きく広い' : v > 0.18 ? '普通' : '小さく整っている';
  static String _symDescJa(double v) =>
      v < 0.05 ? '非常に対称' : v < 0.12 ? '普通の対称' : 'やや非対称';
  static String _foreheadDescJa(double v) =>
      v > 0.15 ? '広く高い' : v > 0.10 ? '普通' : '狭く低い';
  static String _browDescJa(double v) =>
      v < 0.03 ? '目に近い' : v < 0.06 ? '普通' : '目から遠い';

  // ── 얼굴 기술어 (zh) ──────────────────────────────────────────────────────
  static String _eyeDescZh(double v) =>
      v > 0.18 ? '距离宽' : v > 0.14 ? '适中' : '距离窄';
  static String _noseDescZh(double v) =>
      v > 0.6 ? '长且明显' : v > 0.5 ? '均衡' : '短而上翘';
  static String _mouthDescZh(double v) =>
      v > 0.25 ? '大且宽' : v > 0.18 ? '适中' : '小而精致';
  static String _symDescZh(double v) =>
      v < 0.05 ? '高度对称' : v < 0.12 ? '较为对称' : '略微不对称';
  static String _foreheadDescZh(double v) =>
      v > 0.15 ? '宽而高' : v > 0.10 ? '适中' : '窄而低';
  static String _browDescZh(double v) =>
      v < 0.03 ? '靠近眼睛' : v < 0.06 ? '适中' : '远离眼睛';
}
