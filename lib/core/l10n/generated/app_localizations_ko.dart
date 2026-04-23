// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'Aura';

  @override
  String get faceReading => '관상 보기';

  @override
  String get palmReading => '손금 보기';

  @override
  String get faceReadingDesc => '얼굴 특징으로 읽는 당신의 운명';

  @override
  String get palmReadingDesc => '손바닥 선으로 읽는 당신의 미래';

  @override
  String get settings => '설정';

  @override
  String get history => '분석 기록';

  @override
  String get loginBanner => '로그인하면 결과를 저장할 수 있습니다';

  @override
  String get loginPrompt => '결과를 저장하려면 로그인하세요';

  @override
  String get loginWithGoogle => 'Google로 로그인';

  @override
  String get loginWithKakao => '카카오로 로그인';

  @override
  String get skip => '건너뛰기';

  @override
  String get agreeTerms => '이용약관 및 개인정보처리방침에 동의합니다';

  @override
  String get viewResults => '관상 결과 보기';

  @override
  String get analyzing => '분석 중...';

  @override
  String get faceDetected => '얼굴 감지됨';

  @override
  String get stabilizing => '얼굴 안정화 중...';

  @override
  String get stabilityDone => '특이점 추출 완료';

  @override
  String get retry => '다시 보기';

  @override
  String get save => '저장';

  @override
  String get share => '공유';

  @override
  String get sectionForehead => '이마';

  @override
  String get sectionEyes => '눈';

  @override
  String get sectionNose => '코';

  @override
  String get sectionMouth => '입';

  @override
  String get sectionChin => '턱';

  @override
  String get sectionOverall => '종합';

  @override
  String get modelDownloading => 'AI 모델 준비 중';

  @override
  String get modelDownloadDesc => '처음 한 번만 다운로드합니다';

  @override
  String get modelReady => 'AI 모델 준비 완료';

  @override
  String get themeLight => '라이트 모드';

  @override
  String get themeDark => '다크 모드';

  @override
  String get language => '언어';

  @override
  String get model => 'AI 모델';

  @override
  String get clearCache => '캐시 삭제';

  @override
  String get logout => '로그아웃';

  @override
  String get deleteAccount => '회원 탈퇴';

  @override
  String get version => '버전';

  @override
  String get privacyPolicy => '개인정보처리방침';

  @override
  String get termsOfService => '이용약관';

  @override
  String get leftHand => '왼손';

  @override
  String get rightHand => '오른손';

  @override
  String get mainConsultation => '상담 이어가기';

  @override
  String get mainConsultationSubtitle => '분석 결과를 더 깊이 알아보세요';

  @override
  String get mainConsultationLoginRequired => '로그인이 필요합니다';

  @override
  String get consultationListTitle => '상담 기록';

  @override
  String get consultationListEmpty => '아직 상담 기록이 없습니다';

  @override
  String get consultationListEmptyAction => '관상/손금 분석부터 시작하세요';

  @override
  String get consultationListNew => '새 상담';

  @override
  String get consultationDeleteConfirm => '이 상담을 삭제할까요?';

  @override
  String consultationMessageCount(int count) {
    return '$count개 메시지';
  }

  @override
  String get pickerTitle => '분석 선택';

  @override
  String get pickerTabFace => '관상';

  @override
  String get pickerTabPalm => '손금';

  @override
  String get pickerEmpty => '저장된 분석 결과가 없습니다';

  @override
  String get pickerEmptyAction => '분석 시작하기';

  @override
  String get chatInputHint => '질문을 입력하세요';

  @override
  String get chatTitleEdit => '제목 편집';

  @override
  String get chatDeleteConsultation => '상담 삭제';

  @override
  String get chatErrorGeneration => '응답 생성에 실패했습니다. 다시 시도해주세요.';

  @override
  String get resultStartConsultation => '상담하기';

  @override
  String get resultSaveBeforeConsult => '먼저 저장해주세요';

  @override
  String get resultLoginToConsult => '상담하려면 로그인이 필요합니다';
}
