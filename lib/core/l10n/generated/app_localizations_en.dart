// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Aura';

  @override
  String get faceReading => 'Face Reading';

  @override
  String get palmReading => 'Palm Reading';

  @override
  String get faceReadingDesc => 'Discover your destiny through facial features';

  @override
  String get palmReadingDesc => 'Read your future through palm lines';

  @override
  String get settings => 'Settings';

  @override
  String get history => 'History';

  @override
  String get loginBanner => 'Log in to save your results';

  @override
  String get loginPrompt => 'Log in to save your results';

  @override
  String get loginWithGoogle => 'Continue with Google';

  @override
  String get loginWithKakao => 'Continue with Kakao';

  @override
  String get skip => 'Skip';

  @override
  String get agreeTerms => 'I agree to the Terms and Privacy Policy';

  @override
  String get viewResults => 'View Reading Results';

  @override
  String get analyzing => 'Analyzing...';

  @override
  String get faceDetected => 'Face detected';

  @override
  String get stabilizing => 'Stabilizing...';

  @override
  String get stabilityDone => 'Landmarks captured';

  @override
  String get retry => 'Retry';

  @override
  String get save => 'Save';

  @override
  String get share => 'Share';

  @override
  String get sectionForehead => 'Forehead';

  @override
  String get sectionEyes => 'Eyes';

  @override
  String get sectionNose => 'Nose';

  @override
  String get sectionMouth => 'Mouth';

  @override
  String get sectionChin => 'Chin';

  @override
  String get sectionOverall => 'Overall';

  @override
  String get modelDownloading => 'Preparing AI Model';

  @override
  String get modelDownloadDesc => 'One-time download only';

  @override
  String get modelReady => 'AI Model Ready';

  @override
  String get themeLight => 'Light Mode';

  @override
  String get themeDark => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get model => 'AI Model';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get logout => 'Log Out';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get version => 'Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get leftHand => 'Left Hand';

  @override
  String get rightHand => 'Right Hand';

  @override
  String get mainConsultation => 'Continue Consultation';

  @override
  String get mainConsultationSubtitle =>
      'Dive deeper into your reading results';

  @override
  String get mainConsultationLoginRequired => 'Login required';

  @override
  String get consultationListTitle => 'Consultations';

  @override
  String get consultationListEmpty => 'No consultations yet';

  @override
  String get consultationListEmptyAction => 'Start with a face or palm reading';

  @override
  String get consultationListNew => 'New Consultation';

  @override
  String get consultationDeleteConfirm => 'Delete this consultation?';

  @override
  String consultationMessageCount(int count) {
    return '$count messages';
  }

  @override
  String get pickerTitle => 'Select Reading';

  @override
  String get pickerTabFace => 'Face';

  @override
  String get pickerTabPalm => 'Palm';

  @override
  String get pickerEmpty => 'No saved readings found';

  @override
  String get pickerEmptyAction => 'Start a reading';

  @override
  String get chatInputHint => 'Type your question...';

  @override
  String get chatTitleEdit => 'Edit Title';

  @override
  String get chatDeleteConsultation => 'Delete Consultation';

  @override
  String get chatErrorGeneration =>
      'Failed to generate a response. Please try again.';

  @override
  String get resultStartConsultation => 'Start Consultation';

  @override
  String get resultSaveBeforeConsult => 'Please save your results first';

  @override
  String get resultLoginToConsult => 'Login required to start a consultation';

  @override
  String get todayReading => 'Today\'s Reading';

  @override
  String get login => 'Login';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System Default';

  @override
  String get languageSelect => 'Select Language';

  @override
  String get faceAnalysis => 'Face Analysis';

  @override
  String get palmAnalysis => 'Palm Analysis';

  @override
  String get historyEmpty => 'No readings saved yet';

  @override
  String get historyLoginPrompt => 'Log in to view your reading history';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteRecord => 'Delete Record';

  @override
  String get deleteRecordContent =>
      'Delete this reading?\nLinked consultations will also be deleted.\nThis action cannot be undone.';

  @override
  String get deleteFailed => 'Delete failed';

  @override
  String get cacheDeleteConfirm => 'Clear app cache?';

  @override
  String cacheDeleteSuccess(String mb) {
    return 'Cache cleared (${mb}MB)';
  }

  @override
  String get cacheDeleteFailed => 'Failed to clear cache';

  @override
  String get loginRequired => 'Login Required';

  @override
  String get loginRequiredContent =>
      'Login required to save.\nYou will be redirected back after login.';

  @override
  String saveSuccess(String name) {
    return 'Reading saved for $name';
  }

  @override
  String get saveFailed => 'Save failed. Please try again.';

  @override
  String get palmViewResults => 'View Palm Reading Results';

  @override
  String get cameraPermissionRequired => 'Camera Permission Required';

  @override
  String get facePermissionDesc =>
      'Please allow camera access for face analysis';

  @override
  String get palmPermissionDesc =>
      'Please allow camera access for palm analysis';

  @override
  String get openSettings => 'Allow in Settings';

  @override
  String get goBack => 'Go Back';

  @override
  String get palmGuide => 'Show your palm\nfacing the screen';

  @override
  String get aiEngineInitializing => 'Initializing AI engine...';

  @override
  String get faceAnalyzing => 'Reading face...';

  @override
  String get palmAnalyzing => 'Reading palm...';

  @override
  String get faceAnalysisResult => 'Face Reading Result';

  @override
  String get palmAnalysisResult => 'Palm Reading Result';

  @override
  String get analysisError => 'An error occurred during analysis';

  @override
  String get aiModelError => 'AI Model Error';

  @override
  String get modelReinstall => 'Reinstall Model';

  @override
  String get consultationCreateFailed => 'Failed to create consultation';

  @override
  String get sectionLifeline => 'Life Line';

  @override
  String get sectionHeartline => 'Heart Line';

  @override
  String get sectionHeadline => 'Head Line';

  @override
  String get sectionFateline => 'Fate Line';

  @override
  String get sectionHandshape => 'Hand Shape';

  @override
  String palmResultTitle(String hand) {
    return '$hand Palm Reading';
  }

  @override
  String get consultationTitle => 'Consultation';

  @override
  String get consultationNotFound => 'Consultation not found';

  @override
  String get backToList => 'Back to List';

  @override
  String get consultationDeleteContent =>
      'Delete this consultation?\nAll messages will be lost.';

  @override
  String get consultationTitleHint => 'Consultation title';

  @override
  String get consultationEmptyHint => 'Ask anything about your reading results';

  @override
  String get faceConsultation => 'Face Consultation';

  @override
  String get palmConsultation => 'Palm Consultation';

  @override
  String get pickerEmptyFace => 'No saved face readings';

  @override
  String get pickerEmptyPalm => 'No saved palm readings';

  @override
  String get chatGenerating => 'Generating response...';

  @override
  String get copied => 'Copied';

  @override
  String get modelScanning => 'Scanning device...';

  @override
  String get modelScanningDesc => 'Searching for installed AI model';

  @override
  String get modelFound => 'Model Found!';

  @override
  String modelDownloadingWith(String name) {
    return 'Preparing AI Model ($name)';
  }

  @override
  String modelDownloadDescWithSize(String size) {
    return 'One-time download only (approx. ${size}GB)';
  }

  @override
  String get downloadFailed => 'Download Failed';

  @override
  String get errorPrefix => 'Error';

  @override
  String get agreePrefix => 'I agree to: ';

  @override
  String get agreeConnector => ' and ';

  @override
  String get subjectPickerTitle => 'Who is this reading for?';

  @override
  String get subjectPickerSubtitle => 'Select who this reading belongs to';

  @override
  String get subjectPickerCustom => 'Custom';

  @override
  String get subjectPickerCustomHint => 'Enter name or relation';

  @override
  String get subjectPickerConfirm => 'Save';

  @override
  String get subjectMe => 'Me';

  @override
  String get subjectSpouse => 'Spouse';

  @override
  String get subjectFriend => 'Friend';

  @override
  String get subjectParents => 'Parents';

  @override
  String get subjectChild => 'Child';

  @override
  String get subjectSibling => 'Sibling';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count hr ago';
  }

  @override
  String daysAgo(int count) {
    return '$count day ago';
  }
}
