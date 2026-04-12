/// MediaPipe 468 landmarks 중 관상 핵심 17개 인덱스
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
