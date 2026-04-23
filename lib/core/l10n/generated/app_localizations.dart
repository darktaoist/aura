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
