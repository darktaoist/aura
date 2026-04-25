import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In ko, this message translates to:
  /// **'Aura'**
  String get appName;

  /// No description provided for @faceReading.
  ///
  /// In ko, this message translates to:
  /// **'관상 보기'**
  String get faceReading;

  /// No description provided for @palmReading.
  ///
  /// In ko, this message translates to:
  /// **'손금 보기'**
  String get palmReading;

  /// No description provided for @faceReadingDesc.
  ///
  /// In ko, this message translates to:
  /// **'얼굴 특징으로 읽는 당신의 운명'**
  String get faceReadingDesc;

  /// No description provided for @palmReadingDesc.
  ///
  /// In ko, this message translates to:
  /// **'손바닥 선으로 읽는 당신의 미래'**
  String get palmReadingDesc;

  /// No description provided for @settings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings;

  /// No description provided for @history.
  ///
  /// In ko, this message translates to:
  /// **'분석 기록'**
  String get history;

  /// No description provided for @loginBanner.
  ///
  /// In ko, this message translates to:
  /// **'로그인하면 결과를 저장할 수 있습니다'**
  String get loginBanner;

  /// No description provided for @loginPrompt.
  ///
  /// In ko, this message translates to:
  /// **'결과를 저장하려면 로그인하세요'**
  String get loginPrompt;

  /// No description provided for @loginWithGoogle.
  ///
  /// In ko, this message translates to:
  /// **'Google로 로그인'**
  String get loginWithGoogle;

  /// No description provided for @loginWithKakao.
  ///
  /// In ko, this message translates to:
  /// **'카카오로 로그인'**
  String get loginWithKakao;

  /// No description provided for @skip.
  ///
  /// In ko, this message translates to:
  /// **'건너뛰기'**
  String get skip;

  /// No description provided for @agreeTerms.
  ///
  /// In ko, this message translates to:
  /// **'이용약관 및 개인정보처리방침에 동의합니다'**
  String get agreeTerms;

  /// No description provided for @viewResults.
  ///
  /// In ko, this message translates to:
  /// **'관상 결과 보기'**
  String get viewResults;

  /// No description provided for @analyzing.
  ///
  /// In ko, this message translates to:
  /// **'분석 중...'**
  String get analyzing;

  /// No description provided for @faceDetected.
  ///
  /// In ko, this message translates to:
  /// **'얼굴 감지됨'**
  String get faceDetected;

  /// No description provided for @stabilizing.
  ///
  /// In ko, this message translates to:
  /// **'얼굴 안정화 중...'**
  String get stabilizing;

  /// No description provided for @stabilityDone.
  ///
  /// In ko, this message translates to:
  /// **'특이점 추출 완료'**
  String get stabilityDone;

  /// No description provided for @cameraGuideAlign.
  ///
  /// In ko, this message translates to:
  /// **'화면 안에 얼굴을 맞춰주세요'**
  String get cameraGuideAlign;

  /// No description provided for @cameraGuideAlignHand.
  ///
  /// In ko, this message translates to:
  /// **'손바닥을 화면 안에 맞춰주세요'**
  String get cameraGuideAlignHand;

  /// No description provided for @cameraGuideScanning.
  ///
  /// In ko, this message translates to:
  /// **'인식 중입니다. 잠시만 기다려 주세요'**
  String get cameraGuideScanning;

  /// No description provided for @cameraGuideDone.
  ///
  /// In ko, this message translates to:
  /// **'인식 완료! 아래 버튼을 눌러주세요'**
  String get cameraGuideDone;

  /// No description provided for @retry.
  ///
  /// In ko, this message translates to:
  /// **'다시 보기'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// No description provided for @share.
  ///
  /// In ko, this message translates to:
  /// **'공유'**
  String get share;

  /// No description provided for @sectionForehead.
  ///
  /// In ko, this message translates to:
  /// **'이마'**
  String get sectionForehead;

  /// No description provided for @sectionEyes.
  ///
  /// In ko, this message translates to:
  /// **'눈'**
  String get sectionEyes;

  /// No description provided for @sectionNose.
  ///
  /// In ko, this message translates to:
  /// **'코'**
  String get sectionNose;

  /// No description provided for @sectionMouth.
  ///
  /// In ko, this message translates to:
  /// **'입'**
  String get sectionMouth;

  /// No description provided for @sectionChin.
  ///
  /// In ko, this message translates to:
  /// **'턱'**
  String get sectionChin;

  /// No description provided for @sectionOverall.
  ///
  /// In ko, this message translates to:
  /// **'종합'**
  String get sectionOverall;

  /// No description provided for @modelDownloading.
  ///
  /// In ko, this message translates to:
  /// **'AI 모델 준비 중'**
  String get modelDownloading;

  /// No description provided for @modelDownloadDesc.
  ///
  /// In ko, this message translates to:
  /// **'처음 한 번만 다운로드합니다'**
  String get modelDownloadDesc;

  /// No description provided for @modelReady.
  ///
  /// In ko, this message translates to:
  /// **'AI 모델 준비 완료'**
  String get modelReady;

  /// No description provided for @themeLight.
  ///
  /// In ko, this message translates to:
  /// **'라이트 모드'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ko, this message translates to:
  /// **'다크 모드'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get language;

  /// No description provided for @model.
  ///
  /// In ko, this message translates to:
  /// **'AI 모델'**
  String get model;

  /// No description provided for @clearCache.
  ///
  /// In ko, this message translates to:
  /// **'캐시 삭제'**
  String get clearCache;

  /// No description provided for @logout.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In ko, this message translates to:
  /// **'회원 탈퇴'**
  String get deleteAccount;

  /// No description provided for @version.
  ///
  /// In ko, this message translates to:
  /// **'버전'**
  String get version;

  /// No description provided for @privacyPolicy.
  ///
  /// In ko, this message translates to:
  /// **'개인정보처리방침'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In ko, this message translates to:
  /// **'이용약관'**
  String get termsOfService;

  /// No description provided for @leftHand.
  ///
  /// In ko, this message translates to:
  /// **'왼손'**
  String get leftHand;

  /// No description provided for @rightHand.
  ///
  /// In ko, this message translates to:
  /// **'오른손'**
  String get rightHand;

  /// No description provided for @mainConsultation.
  ///
  /// In ko, this message translates to:
  /// **'상담 이어가기'**
  String get mainConsultation;

  /// No description provided for @mainConsultationSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'분석 결과를 더 깊이 알아보세요'**
  String get mainConsultationSubtitle;

  /// No description provided for @mainConsultationLoginRequired.
  ///
  /// In ko, this message translates to:
  /// **'로그인이 필요합니다'**
  String get mainConsultationLoginRequired;

  /// No description provided for @consultationListTitle.
  ///
  /// In ko, this message translates to:
  /// **'상담 기록'**
  String get consultationListTitle;

  /// No description provided for @consultationListEmpty.
  ///
  /// In ko, this message translates to:
  /// **'아직 상담 기록이 없습니다'**
  String get consultationListEmpty;

  /// No description provided for @consultationListEmptyAction.
  ///
  /// In ko, this message translates to:
  /// **'관상/손금 분석부터 시작하세요'**
  String get consultationListEmptyAction;

  /// No description provided for @consultationListNew.
  ///
  /// In ko, this message translates to:
  /// **'새 상담'**
  String get consultationListNew;

  /// No description provided for @consultationDeleteConfirm.
  ///
  /// In ko, this message translates to:
  /// **'이 상담을 삭제할까요?'**
  String get consultationDeleteConfirm;

  /// No description provided for @consultationMessageCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 메시지'**
  String consultationMessageCount(int count);

  /// No description provided for @pickerTitle.
  ///
  /// In ko, this message translates to:
  /// **'분석 선택'**
  String get pickerTitle;

  /// No description provided for @pickerTabFace.
  ///
  /// In ko, this message translates to:
  /// **'관상'**
  String get pickerTabFace;

  /// No description provided for @pickerTabPalm.
  ///
  /// In ko, this message translates to:
  /// **'손금'**
  String get pickerTabPalm;

  /// No description provided for @pickerEmpty.
  ///
  /// In ko, this message translates to:
  /// **'저장된 분석 결과가 없습니다'**
  String get pickerEmpty;

  /// No description provided for @pickerEmptyAction.
  ///
  /// In ko, this message translates to:
  /// **'분석 시작하기'**
  String get pickerEmptyAction;

  /// No description provided for @chatInputHint.
  ///
  /// In ko, this message translates to:
  /// **'질문을 입력하세요'**
  String get chatInputHint;

  /// No description provided for @chatTitleEdit.
  ///
  /// In ko, this message translates to:
  /// **'제목 편집'**
  String get chatTitleEdit;

  /// No description provided for @chatDeleteConsultation.
  ///
  /// In ko, this message translates to:
  /// **'상담 삭제'**
  String get chatDeleteConsultation;

  /// No description provided for @chatErrorGeneration.
  ///
  /// In ko, this message translates to:
  /// **'응답 생성에 실패했습니다. 다시 시도해주세요.'**
  String get chatErrorGeneration;

  /// No description provided for @resultStartConsultation.
  ///
  /// In ko, this message translates to:
  /// **'상담하기'**
  String get resultStartConsultation;

  /// No description provided for @resultSaveBeforeConsult.
  ///
  /// In ko, this message translates to:
  /// **'먼저 저장해주세요'**
  String get resultSaveBeforeConsult;

  /// No description provided for @resultLoginToConsult.
  ///
  /// In ko, this message translates to:
  /// **'상담하려면 로그인이 필요합니다'**
  String get resultLoginToConsult;

  /// No description provided for @todayReading.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 분석'**
  String get todayReading;

  /// No description provided for @login.
  ///
  /// In ko, this message translates to:
  /// **'로그인'**
  String get login;

  /// No description provided for @theme.
  ///
  /// In ko, this message translates to:
  /// **'테마'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템 설정 따름'**
  String get themeSystem;

  /// No description provided for @languageSelect.
  ///
  /// In ko, this message translates to:
  /// **'언어 선택'**
  String get languageSelect;

  /// No description provided for @faceAnalysis.
  ///
  /// In ko, this message translates to:
  /// **'관상 분석'**
  String get faceAnalysis;

  /// No description provided for @palmAnalysis.
  ///
  /// In ko, this message translates to:
  /// **'손금 분석'**
  String get palmAnalysis;

  /// No description provided for @historyEmpty.
  ///
  /// In ko, this message translates to:
  /// **'아직 저장된 분석이 없습니다'**
  String get historyEmpty;

  /// No description provided for @historyLoginPrompt.
  ///
  /// In ko, this message translates to:
  /// **'로그인 후 분석 기록을 확인하세요'**
  String get historyLoginPrompt;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get delete;

  /// No description provided for @deleteRecord.
  ///
  /// In ko, this message translates to:
  /// **'기록 삭제'**
  String get deleteRecord;

  /// No description provided for @deleteRecordContent.
  ///
  /// In ko, this message translates to:
  /// **'이 분석 기록을 삭제하시겠습니까?\n연결된 상담 기록도 함께 삭제됩니다.\n삭제된 기록은 복구할 수 없습니다.'**
  String get deleteRecordContent;

  /// No description provided for @deleteFailed.
  ///
  /// In ko, this message translates to:
  /// **'삭제 실패'**
  String get deleteFailed;

  /// No description provided for @cacheDeleteConfirm.
  ///
  /// In ko, this message translates to:
  /// **'앱 캐시를 삭제하시겠습니까?'**
  String get cacheDeleteConfirm;

  /// No description provided for @cacheDeleteSuccess.
  ///
  /// In ko, this message translates to:
  /// **'캐시 삭제 완료 ({mb}MB)'**
  String cacheDeleteSuccess(String mb);

  /// No description provided for @cacheDeleteFailed.
  ///
  /// In ko, this message translates to:
  /// **'캐시 삭제 실패'**
  String get cacheDeleteFailed;

  /// No description provided for @loginRequired.
  ///
  /// In ko, this message translates to:
  /// **'로그인 필요'**
  String get loginRequired;

  /// No description provided for @loginRequiredContent.
  ///
  /// In ko, this message translates to:
  /// **'저장하려면 로그인이 필요합니다.\n로그인 후 자동으로 저장됩니다.'**
  String get loginRequiredContent;

  /// No description provided for @saveSuccess.
  ///
  /// In ko, this message translates to:
  /// **'{name}님의 결과가 저장되었습니다'**
  String saveSuccess(String name);

  /// No description provided for @saveFailed.
  ///
  /// In ko, this message translates to:
  /// **'저장에 실패했습니다. 다시 시도해주세요.'**
  String get saveFailed;

  /// No description provided for @palmViewResults.
  ///
  /// In ko, this message translates to:
  /// **'손금 결과 보기'**
  String get palmViewResults;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In ko, this message translates to:
  /// **'카메라 권한이 필요합니다'**
  String get cameraPermissionRequired;

  /// No description provided for @facePermissionDesc.
  ///
  /// In ko, this message translates to:
  /// **'얼굴 분석을 위해 카메라 접근 권한을 허용해 주세요'**
  String get facePermissionDesc;

  /// No description provided for @palmPermissionDesc.
  ///
  /// In ko, this message translates to:
  /// **'손금 분석을 위해 카메라 접근 권한을 허용해 주세요'**
  String get palmPermissionDesc;

  /// No description provided for @openSettings.
  ///
  /// In ko, this message translates to:
  /// **'설정에서 권한 허용'**
  String get openSettings;

  /// No description provided for @goBack.
  ///
  /// In ko, this message translates to:
  /// **'돌아가기'**
  String get goBack;

  /// No description provided for @palmGuide.
  ///
  /// In ko, this message translates to:
  /// **'손바닥을 화면 쪽으로\n펼쳐서 보여주세요'**
  String get palmGuide;

  /// No description provided for @aiEngineInitializing.
  ///
  /// In ko, this message translates to:
  /// **'AI 엔진 초기화 중...'**
  String get aiEngineInitializing;

  /// No description provided for @faceAnalyzing.
  ///
  /// In ko, this message translates to:
  /// **'관상 분석 중...'**
  String get faceAnalyzing;

  /// No description provided for @palmAnalyzing.
  ///
  /// In ko, this message translates to:
  /// **'손금 분석 중...'**
  String get palmAnalyzing;

  /// No description provided for @faceAnalysisResult.
  ///
  /// In ko, this message translates to:
  /// **'관상 분석 결과'**
  String get faceAnalysisResult;

  /// No description provided for @palmAnalysisResult.
  ///
  /// In ko, this message translates to:
  /// **'손금 분석 결과'**
  String get palmAnalysisResult;

  /// No description provided for @analysisError.
  ///
  /// In ko, this message translates to:
  /// **'분석 중 오류가 발생했습니다'**
  String get analysisError;

  /// No description provided for @aiModelError.
  ///
  /// In ko, this message translates to:
  /// **'AI 모델 오류'**
  String get aiModelError;

  /// No description provided for @modelReinstall.
  ///
  /// In ko, this message translates to:
  /// **'모델 재설치'**
  String get modelReinstall;

  /// No description provided for @consultationCreateFailed.
  ///
  /// In ko, this message translates to:
  /// **'상담 생성 실패'**
  String get consultationCreateFailed;

  /// No description provided for @sectionLifeline.
  ///
  /// In ko, this message translates to:
  /// **'생명선'**
  String get sectionLifeline;

  /// No description provided for @sectionHeartline.
  ///
  /// In ko, this message translates to:
  /// **'감정선'**
  String get sectionHeartline;

  /// No description provided for @sectionHeadline.
  ///
  /// In ko, this message translates to:
  /// **'두뇌선'**
  String get sectionHeadline;

  /// No description provided for @sectionFateline.
  ///
  /// In ko, this message translates to:
  /// **'운명선'**
  String get sectionFateline;

  /// No description provided for @sectionHandshape.
  ///
  /// In ko, this message translates to:
  /// **'손모양'**
  String get sectionHandshape;

  /// No description provided for @palmResultTitle.
  ///
  /// In ko, this message translates to:
  /// **'{hand} 손금 분석'**
  String palmResultTitle(String hand);

  /// No description provided for @consultationTitle.
  ///
  /// In ko, this message translates to:
  /// **'상담'**
  String get consultationTitle;

  /// No description provided for @consultationNotFound.
  ///
  /// In ko, this message translates to:
  /// **'상담을 찾을 수 없습니다'**
  String get consultationNotFound;

  /// No description provided for @backToList.
  ///
  /// In ko, this message translates to:
  /// **'목록으로'**
  String get backToList;

  /// No description provided for @consultationDeleteContent.
  ///
  /// In ko, this message translates to:
  /// **'이 상담을 삭제할까요?\n대화 내용이 모두 사라집니다.'**
  String get consultationDeleteContent;

  /// No description provided for @consultationTitleHint.
  ///
  /// In ko, this message translates to:
  /// **'상담 제목'**
  String get consultationTitleHint;

  /// No description provided for @consultationEmptyHint.
  ///
  /// In ko, this message translates to:
  /// **'분석 결과에 대해 궁금한 점을 물어보세요'**
  String get consultationEmptyHint;

  /// No description provided for @faceConsultation.
  ///
  /// In ko, this message translates to:
  /// **'관상 상담'**
  String get faceConsultation;

  /// No description provided for @palmConsultation.
  ///
  /// In ko, this message translates to:
  /// **'손금 상담'**
  String get palmConsultation;

  /// No description provided for @pickerEmptyFace.
  ///
  /// In ko, this message translates to:
  /// **'저장된 관상 분석이 없습니다'**
  String get pickerEmptyFace;

  /// No description provided for @pickerEmptyPalm.
  ///
  /// In ko, this message translates to:
  /// **'저장된 손금 분석이 없습니다'**
  String get pickerEmptyPalm;

  /// No description provided for @chatGenerating.
  ///
  /// In ko, this message translates to:
  /// **'응답 생성 중...'**
  String get chatGenerating;

  /// No description provided for @copied.
  ///
  /// In ko, this message translates to:
  /// **'복사되었습니다'**
  String get copied;

  /// No description provided for @modelScanning.
  ///
  /// In ko, this message translates to:
  /// **'기기 확인 중...'**
  String get modelScanning;

  /// No description provided for @modelScanningDesc.
  ///
  /// In ko, this message translates to:
  /// **'설치된 AI 모델을 찾고 있습니다'**
  String get modelScanningDesc;

  /// No description provided for @modelFound.
  ///
  /// In ko, this message translates to:
  /// **'모델 발견!'**
  String get modelFound;

  /// No description provided for @modelDownloadingWith.
  ///
  /// In ko, this message translates to:
  /// **'AI 모델 준비 중 ({name})'**
  String modelDownloadingWith(String name);

  /// No description provided for @modelDownloadDescWithSize.
  ///
  /// In ko, this message translates to:
  /// **'처음 한 번만 다운로드합니다 (약 {size}GB)'**
  String modelDownloadDescWithSize(String size);

  /// No description provided for @downloadFailed.
  ///
  /// In ko, this message translates to:
  /// **'다운로드 실패'**
  String get downloadFailed;

  /// No description provided for @errorPrefix.
  ///
  /// In ko, this message translates to:
  /// **'오류'**
  String get errorPrefix;

  /// No description provided for @agreePrefix.
  ///
  /// In ko, this message translates to:
  /// **'동의합니다: '**
  String get agreePrefix;

  /// No description provided for @agreeConnector.
  ///
  /// In ko, this message translates to:
  /// **' 및 '**
  String get agreeConnector;

  /// No description provided for @subjectPickerTitle.
  ///
  /// In ko, this message translates to:
  /// **'누구의 분석인가요?'**
  String get subjectPickerTitle;

  /// No description provided for @subjectPickerSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'분석 결과를 저장할 대상을 선택하세요'**
  String get subjectPickerSubtitle;

  /// No description provided for @subjectPickerCustom.
  ///
  /// In ko, this message translates to:
  /// **'직접 입력'**
  String get subjectPickerCustom;

  /// No description provided for @subjectPickerCustomHint.
  ///
  /// In ko, this message translates to:
  /// **'이름 또는 관계를 입력하세요'**
  String get subjectPickerCustomHint;

  /// No description provided for @subjectPickerConfirm.
  ///
  /// In ko, this message translates to:
  /// **'저장하기'**
  String get subjectPickerConfirm;

  /// No description provided for @subjectMe.
  ///
  /// In ko, this message translates to:
  /// **'나'**
  String get subjectMe;

  /// No description provided for @subjectSpouse.
  ///
  /// In ko, this message translates to:
  /// **'배우자'**
  String get subjectSpouse;

  /// No description provided for @subjectFriend.
  ///
  /// In ko, this message translates to:
  /// **'친구'**
  String get subjectFriend;

  /// No description provided for @subjectParents.
  ///
  /// In ko, this message translates to:
  /// **'부모님'**
  String get subjectParents;

  /// No description provided for @subjectChild.
  ///
  /// In ko, this message translates to:
  /// **'자녀'**
  String get subjectChild;

  /// No description provided for @subjectSibling.
  ///
  /// In ko, this message translates to:
  /// **'형제/자매'**
  String get subjectSibling;

  /// No description provided for @justNow.
  ///
  /// In ko, this message translates to:
  /// **'방금'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In ko, this message translates to:
  /// **'{count}분 전'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In ko, this message translates to:
  /// **'{count}시간 전'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In ko, this message translates to:
  /// **'{count}일 전'**
  String daysAgo(int count);

  /// No description provided for @homeGreeting.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 아우라'**
  String get homeGreeting;

  /// No description provided for @homeDailyFallback.
  ///
  /// In ko, this message translates to:
  /// **'오늘 하루도 당신의 결이 흐려지지 않기를.'**
  String get homeDailyFallback;

  /// No description provided for @homeFaceLabel.
  ///
  /// In ko, this message translates to:
  /// **'AI 관상'**
  String get homeFaceLabel;

  /// No description provided for @homeFaceTitle.
  ///
  /// In ko, this message translates to:
  /// **'얼굴을 읽다'**
  String get homeFaceTitle;

  /// No description provided for @homeFaceDesc.
  ///
  /// In ko, this message translates to:
  /// **'468 랜드마크'**
  String get homeFaceDesc;

  /// No description provided for @homePalmLabel.
  ///
  /// In ko, this message translates to:
  /// **'AI 손금'**
  String get homePalmLabel;

  /// No description provided for @homePalmTitle.
  ///
  /// In ko, this message translates to:
  /// **'손을 읽다'**
  String get homePalmTitle;

  /// No description provided for @homePalmDesc.
  ///
  /// In ko, this message translates to:
  /// **'21 랜드마크'**
  String get homePalmDesc;

  /// No description provided for @homeResumeTitle.
  ///
  /// In ko, this message translates to:
  /// **'이어가기'**
  String get homeResumeTitle;

  /// No description provided for @homeResumeEmpty.
  ///
  /// In ko, this message translates to:
  /// **'아직 진행 중인 상담이 없어요.'**
  String get homeResumeEmpty;

  /// No description provided for @commonSeeAll.
  ///
  /// In ko, this message translates to:
  /// **'모두 보기'**
  String get commonSeeAll;

  /// No description provided for @commonGuest.
  ///
  /// In ko, this message translates to:
  /// **'게스트'**
  String get commonGuest;

  /// No description provided for @commonShare.
  ///
  /// In ko, this message translates to:
  /// **'공유'**
  String get commonShare;

  /// No description provided for @commonSave.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get commonSave;

  /// No description provided for @commonCopied.
  ///
  /// In ko, this message translates to:
  /// **'복사됨'**
  String get commonCopied;

  /// No description provided for @commonLoadError.
  ///
  /// In ko, this message translates to:
  /// **'불러오지 못했어요'**
  String get commonLoadError;

  /// No description provided for @historyTitle.
  ///
  /// In ko, this message translates to:
  /// **'기록'**
  String get historyTitle;

  /// No description provided for @historyAll.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get historyAll;

  /// No description provided for @historyFace.
  ///
  /// In ko, this message translates to:
  /// **'관상'**
  String get historyFace;

  /// No description provided for @historyPalm.
  ///
  /// In ko, this message translates to:
  /// **'손금'**
  String get historyPalm;

  /// No description provided for @settingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settingsTitle;

  /// No description provided for @faceResultTitle.
  ///
  /// In ko, this message translates to:
  /// **'관상 리포트'**
  String get faceResultTitle;

  /// No description provided for @faceResultAnalyzedAt.
  ///
  /// In ko, this message translates to:
  /// **'{time} 분석'**
  String faceResultAnalyzedAt(String time);

  /// No description provided for @faceResultStreamingTitle.
  ///
  /// In ko, this message translates to:
  /// **'분석이 한창 진행중이에요'**
  String get faceResultStreamingTitle;

  /// No description provided for @faceResultReadyTitle.
  ///
  /// In ko, this message translates to:
  /// **'리포트가 준비되었어요'**
  String get faceResultReadyTitle;

  /// No description provided for @resultConsult.
  ///
  /// In ko, this message translates to:
  /// **'AI에게 상담하기'**
  String get resultConsult;

  /// No description provided for @consultationsTitle.
  ///
  /// In ko, this message translates to:
  /// **'상담'**
  String get consultationsTitle;

  /// No description provided for @consultationAuraTitle.
  ///
  /// In ko, this message translates to:
  /// **'Aura'**
  String get consultationAuraTitle;

  /// No description provided for @consultationSubjectYou.
  ///
  /// In ko, this message translates to:
  /// **'당신의 분석 기반'**
  String get consultationSubjectYou;

  /// No description provided for @consultationContextTitle.
  ///
  /// In ko, this message translates to:
  /// **'분석 컨텍스트'**
  String get consultationContextTitle;

  /// No description provided for @consultationComposerHint.
  ///
  /// In ko, this message translates to:
  /// **'Aura에게 물어보기…'**
  String get consultationComposerHint;

  /// No description provided for @consultationEmptyTitle.
  ///
  /// In ko, this message translates to:
  /// **'아직 상담 기록이 없어요'**
  String get consultationEmptyTitle;

  /// No description provided for @consultationEmptyBody.
  ///
  /// In ko, this message translates to:
  /// **'분석 결과를 열고 궁금한 점을 물어보세요.'**
  String get consultationEmptyBody;

  /// No description provided for @consultationStart.
  ///
  /// In ko, this message translates to:
  /// **'새 상담 시작'**
  String get consultationStart;

  /// No description provided for @authTagline.
  ///
  /// In ko, this message translates to:
  /// **'얼굴과 손으로 읽는 AI 관상·손금'**
  String get authTagline;

  /// No description provided for @authAgreeTerms.
  ///
  /// In ko, this message translates to:
  /// **'이용약관에 동의합니다'**
  String get authAgreeTerms;

  /// No description provided for @authAgreePrivacy.
  ///
  /// In ko, this message translates to:
  /// **'개인정보 처리방침에 동의합니다'**
  String get authAgreePrivacy;

  /// No description provided for @authSignInGoogle.
  ///
  /// In ko, this message translates to:
  /// **'Google로 계속하기'**
  String get authSignInGoogle;

  /// No description provided for @authSignInApple.
  ///
  /// In ko, this message translates to:
  /// **'Apple로 계속하기'**
  String get authSignInApple;

  /// No description provided for @authContinueGuest.
  ///
  /// In ko, this message translates to:
  /// **'둘러보기 · 게스트로 시작'**
  String get authContinueGuest;

  /// No description provided for @settingsSectionAnalysis.
  ///
  /// In ko, this message translates to:
  /// **'분석'**
  String get settingsSectionAnalysis;

  /// No description provided for @settingsSectionPrivacy.
  ///
  /// In ko, this message translates to:
  /// **'개인정보 · 법적'**
  String get settingsSectionPrivacy;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In ko, this message translates to:
  /// **'앱 정보'**
  String get settingsSectionAbout;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
