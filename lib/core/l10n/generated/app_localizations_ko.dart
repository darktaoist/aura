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

  @override
  String get todayReading => '오늘의 분석';

  @override
  String get login => '로그인';

  @override
  String get theme => '테마';

  @override
  String get themeSystem => '시스템 설정 따름';

  @override
  String get languageSelect => '언어 선택';

  @override
  String get faceAnalysis => '관상 분석';

  @override
  String get palmAnalysis => '손금 분석';

  @override
  String get historyEmpty => '아직 저장된 분석이 없습니다';

  @override
  String get historyLoginPrompt => '로그인 후 분석 기록을 확인하세요';

  @override
  String get cancel => '취소';

  @override
  String get delete => '삭제';

  @override
  String get deleteRecord => '기록 삭제';

  @override
  String get deleteRecordContent =>
      '이 분석 기록을 삭제하시겠습니까?\n연결된 상담 기록도 함께 삭제됩니다.\n삭제된 기록은 복구할 수 없습니다.';

  @override
  String get deleteFailed => '삭제 실패';

  @override
  String get cacheDeleteConfirm => '앱 캐시를 삭제하시겠습니까?';

  @override
  String cacheDeleteSuccess(String mb) {
    return '캐시 삭제 완료 (${mb}MB)';
  }

  @override
  String get cacheDeleteFailed => '캐시 삭제 실패';

  @override
  String get loginRequired => '로그인 필요';

  @override
  String get loginRequiredContent => '저장하려면 로그인이 필요합니다.\n로그인 후 자동으로 저장됩니다.';

  @override
  String saveSuccess(String name) {
    return '$name님의 결과가 저장되었습니다';
  }

  @override
  String get saveFailed => '저장에 실패했습니다. 다시 시도해주세요.';

  @override
  String get palmViewResults => '손금 결과 보기';

  @override
  String get cameraPermissionRequired => '카메라 권한이 필요합니다';

  @override
  String get facePermissionDesc => '얼굴 분석을 위해 카메라 접근 권한을 허용해 주세요';

  @override
  String get palmPermissionDesc => '손금 분석을 위해 카메라 접근 권한을 허용해 주세요';

  @override
  String get openSettings => '설정에서 권한 허용';

  @override
  String get goBack => '돌아가기';

  @override
  String get palmGuide => '손바닥을 화면 쪽으로\n펼쳐서 보여주세요';

  @override
  String get aiEngineInitializing => 'AI 엔진 초기화 중...';

  @override
  String get faceAnalyzing => '관상 분석 중...';

  @override
  String get palmAnalyzing => '손금 분석 중...';

  @override
  String get faceAnalysisResult => '관상 분석 결과';

  @override
  String get palmAnalysisResult => '손금 분석 결과';

  @override
  String get analysisError => '분석 중 오류가 발생했습니다';

  @override
  String get aiModelError => 'AI 모델 오류';

  @override
  String get modelReinstall => '모델 재설치';

  @override
  String get consultationCreateFailed => '상담 생성 실패';

  @override
  String get sectionLifeline => '생명선';

  @override
  String get sectionHeartline => '감정선';

  @override
  String get sectionHeadline => '두뇌선';

  @override
  String get sectionFateline => '운명선';

  @override
  String get sectionHandshape => '손모양';

  @override
  String palmResultTitle(String hand) {
    return '$hand 손금 분석';
  }

  @override
  String get consultationTitle => '상담';

  @override
  String get consultationNotFound => '상담을 찾을 수 없습니다';

  @override
  String get backToList => '목록으로';

  @override
  String get consultationDeleteContent => '이 상담을 삭제할까요?\n대화 내용이 모두 사라집니다.';

  @override
  String get consultationTitleHint => '상담 제목';

  @override
  String get consultationEmptyHint => '분석 결과에 대해 궁금한 점을 물어보세요';

  @override
  String get faceConsultation => '관상 상담';

  @override
  String get palmConsultation => '손금 상담';

  @override
  String get pickerEmptyFace => '저장된 관상 분석이 없습니다';

  @override
  String get pickerEmptyPalm => '저장된 손금 분석이 없습니다';

  @override
  String get chatGenerating => '응답 생성 중...';

  @override
  String get copied => '복사되었습니다';

  @override
  String get modelScanning => '기기 확인 중...';

  @override
  String get modelScanningDesc => '설치된 AI 모델을 찾고 있습니다';

  @override
  String get modelFound => '모델 발견!';

  @override
  String modelDownloadingWith(String name) {
    return 'AI 모델 준비 중 ($name)';
  }

  @override
  String modelDownloadDescWithSize(String size) {
    return '처음 한 번만 다운로드합니다 (약 ${size}GB)';
  }

  @override
  String get downloadFailed => '다운로드 실패';

  @override
  String get errorPrefix => '오류';

  @override
  String get agreePrefix => '동의합니다: ';

  @override
  String get agreeConnector => ' 및 ';

  @override
  String get subjectPickerTitle => '누구의 분석인가요?';

  @override
  String get subjectPickerSubtitle => '분석 결과를 저장할 대상을 선택하세요';

  @override
  String get subjectPickerCustom => '직접 입력';

  @override
  String get subjectPickerCustomHint => '이름 또는 관계를 입력하세요';

  @override
  String get subjectPickerConfirm => '저장하기';

  @override
  String get subjectMe => '나';

  @override
  String get subjectSpouse => '배우자';

  @override
  String get subjectFriend => '친구';

  @override
  String get subjectParents => '부모님';

  @override
  String get subjectChild => '자녀';

  @override
  String get subjectSibling => '형제/자매';

  @override
  String get justNow => '방금';

  @override
  String minutesAgo(int count) {
    return '$count분 전';
  }

  @override
  String hoursAgo(int count) {
    return '$count시간 전';
  }

  @override
  String daysAgo(int count) {
    return '$count일 전';
  }

  @override
  String get homeGreeting => '오늘의 아우라';

  @override
  String get homeDailyFallback => '오늘 하루도 당신의 결이 흐려지지 않기를.';

  @override
  String get homeFaceLabel => 'AI 관상';

  @override
  String get homeFaceTitle => '얼굴을 읽다';

  @override
  String get homeFaceDesc => '468 랜드마크';

  @override
  String get homePalmLabel => 'AI 손금';

  @override
  String get homePalmTitle => '손을 읽다';

  @override
  String get homePalmDesc => '21 랜드마크';

  @override
  String get homeResumeTitle => '이어가기';

  @override
  String get homeResumeEmpty => '아직 진행 중인 상담이 없어요.';

  @override
  String get commonSeeAll => '모두 보기';

  @override
  String get commonGuest => '게스트';

  @override
  String get commonShare => '공유';

  @override
  String get commonSave => '저장';

  @override
  String get commonCopied => '복사됨';

  @override
  String get commonLoadError => '불러오지 못했어요';

  @override
  String get historyTitle => '기록';

  @override
  String get historyAll => '전체';

  @override
  String get historyFace => '관상';

  @override
  String get historyPalm => '손금';

  @override
  String get settingsTitle => '설정';

  @override
  String get faceResultTitle => '관상 리포트';

  @override
  String faceResultAnalyzedAt(String time) {
    return '$time 분석';
  }

  @override
  String get faceResultStreamingTitle => '분석이 한창 진행중이에요';

  @override
  String get faceResultReadyTitle => '리포트가 준비되었어요';

  @override
  String get resultConsult => 'AI에게 상담하기';

  @override
  String get consultationsTitle => '상담';

  @override
  String get consultationAuraTitle => 'Aura';

  @override
  String get consultationSubjectYou => '당신의 분석 기반';

  @override
  String get consultationContextTitle => '분석 컨텍스트';

  @override
  String get consultationComposerHint => 'Aura에게 물어보기…';

  @override
  String get consultationEmptyTitle => '아직 상담 기록이 없어요';

  @override
  String get consultationEmptyBody => '분석 결과를 열고 궁금한 점을 물어보세요.';

  @override
  String get consultationStart => '새 상담 시작';

  @override
  String get authTagline => '얼굴과 손으로 읽는 AI 관상·손금';

  @override
  String get authAgreeTerms => '이용약관에 동의합니다';

  @override
  String get authAgreePrivacy => '개인정보 처리방침에 동의합니다';

  @override
  String get authSignInGoogle => 'Google로 계속하기';

  @override
  String get authSignInApple => 'Apple로 계속하기';

  @override
  String get authContinueGuest => '둘러보기 · 게스트로 시작';

  @override
  String get settingsSectionAnalysis => '분석';

  @override
  String get settingsSectionPrivacy => '개인정보 · 법적';

  @override
  String get settingsSectionAbout => '앱 정보';
}
