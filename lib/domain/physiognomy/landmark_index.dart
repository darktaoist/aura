/// MediaPipe 468 landmarks 중 관상 핵심 17개 인덱스 (KO 기본값)
const Map<String, int> kKeyLandmarks = {
  '이마':      10,
  '코끝':       4,
  '코다리':   168,
  '인중':       0,
  '턱':       152,
  '왼눈(내각)': 133,
  '왼눈(외각)':  33,
  '오른눈(내각)': 362,
  '오른눈(외각)': 263,
  '입(왼)':    61,
  '입(오른)':  291,
  '왼볼':     234,
  '오른볼':   454,
  '왼눈썹(내)': 107,
  '왼눈썹(외)':  46,
  '오른눈썹(내)': 336,
  '오른눈썹(외)': 276,
};

/// 랜드마크 인덱스 → 로케일별 표시 라벨 (index → label)
Map<int, String> keyLandmarkLabels(String locale) {
  switch (locale) {
    case 'en':
      return {
        10: 'Forehead', 4: 'Nose Tip', 168: 'Bridge', 0: 'Philtrum',
        152: 'Chin', 133: 'L.Eye(in)', 33: 'L.Eye(out)',
        362: 'R.Eye(in)', 263: 'R.Eye(out)', 61: 'Mouth(L)',
        291: 'Mouth(R)', 234: 'L.Cheek', 454: 'R.Cheek',
        107: 'L.Brow(in)', 46: 'L.Brow(out)',
        336: 'R.Brow(in)', 276: 'R.Brow(out)',
      };
    case 'ja':
      return {
        10: '額', 4: '鼻先', 168: '鼻筋', 0: '人中',
        152: '顎', 133: '左目(内)', 33: '左目(外)',
        362: '右目(内)', 263: '右目(外)', 61: '口(左)',
        291: '口(右)', 234: '左頬', 454: '右頬',
        107: '左眉(内)', 46: '左眉(外)',
        336: '右眉(内)', 276: '右眉(外)',
      };
    case 'zh':
      return {
        10: '额头', 4: '鼻尖', 168: '鼻梁', 0: '人中',
        152: '下巴', 133: '左眼(内)', 33: '左眼(外)',
        362: '右眼(内)', 263: '右眼(外)', 61: '嘴(左)',
        291: '嘴(右)', 234: '左颊', 454: '右颊',
        107: '左眉(内)', 46: '左眉(外)',
        336: '右眉(内)', 276: '右眉(外)',
      };
    default: // 'ko'
      return {
        10: '이마', 4: '코끝', 168: '코다리', 0: '인중',
        152: '턱', 133: '왼눈(내각)', 33: '왼눈(외각)',
        362: '오른눈(내각)', 263: '오른눈(외각)', 61: '입(왼)',
        291: '입(오른)', 234: '왼볼', 454: '오른볼',
        107: '왼눈썹(내)', 46: '왼눈썹(외)',
        336: '오른눈썹(내)', 276: '오른눈썹(외)',
      };
  }
}

/// 파생 지표 계산에 사용하는 인덱스 쌍
class LandmarkPairs {
  static const int foreheadTop    = 10;
  static const int chin           = 152;
  static const int noseTip        = 4;
  static const int noseBridge     = 168;
  static const int leftEyeInner   = 133;
  static const int rightEyeInner  = 362;
  static const int mouthLeft      = 61;
  static const int mouthRight     = 291;
  static const int leftBrowInner  = 107;

  /// 파생 지표 계산에 필요한 최소 랜드마크 수 (MediaPipe 전체 468개)
  static const int requiredSize = 468;

  LandmarkPairs._();
}
