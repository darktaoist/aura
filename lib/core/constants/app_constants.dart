/// 환경변수 키 (--dart-define 으로 주입)
class Env {
  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  Env._();
}

/// 앱 전역 상수
class AppConst {
  // 카메라
  static const int cameraFpsThrottle = 15;       // 목표 프레임
  static const int frameThrottleMs   = 66;       // 1000/15
  static const int logEveryNFrames   = 30;

  // 분석
  static const int stabilityFrames   = 45;       // 3초 × 15fps
  static const double stabilityScore = 0.7;      // 최소 score 임계값
  static const int gemmaIntervalSec  = 5;        // 실시간 오버레이 분석 간격

  // Gemma
  static const int gemmaMaxTokens    = 2048;
  static const double gemmaTemp      = 0.7;
  static const int gemmaTopK         = 40;

  // RAG
  static const int ragTopK           = 5;

  // 지원 언어
  static const List<String> supportedLocales = ['ko', 'en', 'ja', 'zh'];

  AppConst._();
}
