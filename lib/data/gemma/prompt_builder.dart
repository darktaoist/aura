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
사용자가 제공하는 얼굴 특징 데이터와 관상학 지식을 바탕으로 상세한 관상 분석을 제공하세요.

규칙:
- 반드시 한국어로 답변
- 총 1000자 이상 작성
- 단정적 표현("반드시", "틀림없이", "무조건") 사용 금지
- 다음 6개 섹션으로 구성: ## 이마 ## 눈 ## 코 ## 입 ## 턱 ## 종합
- 각 섹션은 150자 이상
- 긍정적·부정적 특성 균형 있게 서술
- 전통 관상학 용어와 현대적 해석 병행''',

  'en': '''You are a traditional East Asian physiognomy expert with 20 years of experience.
Provide a detailed facial reading based on the measurement data and physiognomy knowledge.

Rules:
- Write in English
- At least 1000 characters total
- Avoid absolute statements ("definitely", "certainly", "without doubt")
- Use 6 sections: ## Forehead ## Eyes ## Nose ## Mouth ## Chin ## Overall
- Each section at least 150 characters
- Balance positive and negative traits
- Combine traditional terminology with modern interpretation''',

  'ja': '''あなたは20年の経験を持つ東洋観相学の専門家です。
顔の特徴データと観相学の知識をもとに、詳細な観相分析を提供してください。

ルール：
- 日本語で回答
- 合計1000字以上
- 断定的表現（「必ず」「間違いなく」）使用禁止
- 次の6セクションで構成：## 額 ## 目 ## 鼻 ## 口 ## 顎 ## 総合
- 各セクション150字以上
- 長所・短所をバランスよく記述''',

  'zh': '''您是拥有20年经验的东方面相学专家。
请根据面部特征数据和面相学知识提供详细的面相分析。

规则：
- 用中文回答
- 总计1000字以上
- 禁止使用绝对性表达（"一定"、"必然"、"肯定"）
- 使用6个章节：## 额头 ## 眼睛 ## 鼻子 ## 嘴巴 ## 下巴 ## 综合
- 每个章节150字以上
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
사용자가 제공하는 손 특징 데이터와 손금학 지식을 바탕으로 상세한 손금 분석을 제공하세요.

규칙:
- 반드시 한국어로 답변
- 총 1000자 이상 작성
- 단정적 표현("반드시", "틀림없이", "무조건") 사용 금지
- 다음 6개 섹션으로 구성: ## 생명선 ## 감정선 ## 두뇌선 ## 운명선 ## 손모양 ## 종합
- 각 섹션은 150자 이상
- 긍정적·부정적 특성 균형 있게 서술
- 전통 손금술 용어와 현대적 해석 병행''',

  'en': '''You are a traditional palmistry expert with 20 years of experience.
Provide a detailed palm reading based on the measurement data and palmistry knowledge.

Rules:
- Write in English
- At least 1000 characters total
- Avoid absolute statements ("definitely", "certainly", "without doubt")
- Use 6 sections: ## Life Line ## Heart Line ## Head Line ## Fate Line ## Hand Shape ## Overall
- Each section at least 150 characters
- Balance positive and negative traits
- Combine traditional terminology with modern interpretation''',

  'ja': '''あなたは20年の経験を持つ東洋手相術の専門家です。
手の特徴データと手相学の知識をもとに、詳細な手相分析を提供してください。

ルール：
- 日本語で回答
- 合計1000字以上
- 断定的表現（「必ず」「間違いなく」）使用禁止
- 次の6セクションで構成：## 生命線 ## 感情線 ## 頭脳線 ## 運命線 ## 手の形 ## 総合
- 各セクション150字以上
- 長所・短所をバランスよく記述''',

  'zh': '''您是拥有20年经验的东方手相学专家。
请根据手部特征数据和手相学知识提供详细的手相分析。

规则：
- 用中文回答
- 总计1000字以上
- 禁止使用绝对性表达（"一定"、"必然"、"肯定"）
- 使用6个章节：## 生命线 ## 感情线 ## 头脑线 ## 命运线 ## 手形 ## 综合
- 每个章节150字以上
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
        : '\n\n참고 지식:\n${ragChunks.map((c) => '- $c').join('\n')}';

    return '$featureText$ragSection\n\n상세 관상 분석을 섹션별로 작성해 주세요.';
  }

  /// 손금 결과화면용 장문 사용자 프롬프트
  static String buildPalmLongFormPrompt({
    required PalmLandmarkResult result,
    required String locale,
    List<String> ragChunks = const [],
  }) {
    final f = result.features;
    final handLabel = result.isLeftHand ? '왼손' : '오른손';
    final ragSection = ragChunks.isEmpty
        ? ''
        : '\n\n참고 지식:\n${ragChunks.map((c) => '- $c').join('\n')}';

    final featureText = '''
손 정보: $handLabel
측정 데이터:
- 손바닥 너비: ${_palmWidthDesc(f.palmWidth)}
- 엄지 길이: ${_fingerLengthDesc(f.thumbLength)}
- 검지 길이: ${_fingerLengthDesc(f.indexLength)}
- 중지 길이: ${_fingerLengthDesc(f.middleLength)}
- 약지 길이: ${_fingerLengthDesc(f.ringLength)}
- 소지 길이: ${_fingerLengthDesc(f.pinkyLength)}
- 손가락 펼침: ${_spreadDesc(f.fingerSpread)}''';

    return '$featureText$ragSection\n\n상세 손금 분석을 섹션별로 작성해 주세요.';
  }

  static String _palmWidthDesc(double v) =>
      v > 0.20 ? '넓음' : v > 0.14 ? '보통' : '좁음';

  static String _fingerLengthDesc(double v) =>
      v > 0.20 ? '길고 뚜렷함' : v > 0.13 ? '보통' : '짧음';

  static String _spreadDesc(double v) =>
      v > 0.12 ? '넓게 펼침' : v > 0.07 ? '보통' : '모아짐';

  static String _buildFeatureText(FaceFeatures f, String locale) {
    final eyeDesc      = _eyeDesc(f.eyeSpan);
    final noseDesc     = _noseDesc(f.noseRatio);
    final mouthDesc    = _mouthDesc(f.mouthWidth);
    final symDesc      = _symDesc(f.symmetry);
    final foreheadDesc = _foreheadDesc(f.foreheadHeight);
    final browDesc     = _browDesc(f.eyebrowDistance);

    return '''
측정 데이터:
- 이마: $foreheadDesc
- 눈 간격: $eyeDesc
- 코 형태: $noseDesc
- 입 크기: $mouthDesc
- 눈썹: $browDesc
- 좌우 대칭: $symDesc''';
  }

  // 기술어 변환 헬퍼
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
}
