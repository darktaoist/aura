// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Aura';

  @override
  String get faceReading => '観相';

  @override
  String get palmReading => '手相';

  @override
  String get faceReadingDesc => '顔の特徴から読む運命';

  @override
  String get palmReadingDesc => '手のひらの線から読む未来';

  @override
  String get settings => '設定';

  @override
  String get history => '履歴';

  @override
  String get loginBanner => 'ログインして結果を保存しましょう';

  @override
  String get loginPrompt => '結果を保存するにはログインしてください';

  @override
  String get loginWithGoogle => 'Googleでログイン';

  @override
  String get loginWithKakao => 'カカオでログイン';

  @override
  String get skip => 'スキップ';

  @override
  String get agreeTerms => '利用規約とプライバシーポリシーに同意します';

  @override
  String get viewResults => '観相結果を見る';

  @override
  String get analyzing => '分析中...';

  @override
  String get faceDetected => '顔を検出しました';

  @override
  String get stabilizing => '安定化中...';

  @override
  String get stabilityDone => '特徴点の抽出完了';

  @override
  String get cameraGuideAlign => '顔を画面内に合わせてください';

  @override
  String get cameraGuideAlignHand => '手のひらを画面内に入れてください';

  @override
  String get cameraGuideScanning => 'スキャン中です。しばらくお待ちください';

  @override
  String get cameraGuideDone => '完了！下のボタンを押してください';

  @override
  String get retry => 'もう一度';

  @override
  String get save => '保存';

  @override
  String get share => '共有';

  @override
  String get sectionForehead => '額';

  @override
  String get sectionEyes => '目';

  @override
  String get sectionNose => '鼻';

  @override
  String get sectionMouth => '口';

  @override
  String get sectionChin => '顎';

  @override
  String get sectionOverall => '総合';

  @override
  String get modelDownloading => 'AIモデル準備中';

  @override
  String get modelDownloadDesc => '初回のみダウンロードします';

  @override
  String get modelReady => 'AIモデル準備完了';

  @override
  String get themeLight => 'ライトモード';

  @override
  String get themeDark => 'ダークモード';

  @override
  String get language => '言語';

  @override
  String get model => 'AIモデル';

  @override
  String get clearCache => 'キャッシュ削除';

  @override
  String get logout => 'ログアウト';

  @override
  String get deleteAccount => 'アカウント削除';

  @override
  String get version => 'バージョン';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get termsOfService => '利用規約';

  @override
  String get leftHand => '左手';

  @override
  String get rightHand => '右手';

  @override
  String get mainConsultation => '相談を続ける';

  @override
  String get mainConsultationSubtitle => '分析結果をさらに深く掘り下げましょう';

  @override
  String get mainConsultationLoginRequired => 'ログインが必要です';

  @override
  String get consultationListTitle => '相談履歴';

  @override
  String get consultationListEmpty => 'まだ相談履歴がありません';

  @override
  String get consultationListEmptyAction => '観相・手相の分析から始めましょう';

  @override
  String get consultationListNew => '新しい相談';

  @override
  String get consultationDeleteConfirm => 'この相談を削除しますか？';

  @override
  String consultationMessageCount(int count) {
    return '$count件のメッセージ';
  }

  @override
  String get pickerTitle => '分析を選択';

  @override
  String get pickerTabFace => '観相';

  @override
  String get pickerTabPalm => '手相';

  @override
  String get pickerEmpty => '保存された分析結果がありません';

  @override
  String get pickerEmptyAction => '分析を始める';

  @override
  String get chatInputHint => '質問を入力してください';

  @override
  String get chatTitleEdit => 'タイトルを編集';

  @override
  String get chatDeleteConsultation => '相談を削除';

  @override
  String get chatErrorGeneration => '応答の生成に失敗しました。もう一度お試しください。';

  @override
  String get resultStartConsultation => '相談する';

  @override
  String get resultSaveBeforeConsult => '先に保存してください';

  @override
  String get resultLoginToConsult => '相談にはログインが必要です';

  @override
  String get todayReading => '今日の分析';

  @override
  String get login => 'ログイン';

  @override
  String get theme => 'テーマ';

  @override
  String get themeSystem => 'システム設定に従う';

  @override
  String get languageSelect => '言語を選択';

  @override
  String get faceAnalysis => '観相分析';

  @override
  String get palmAnalysis => '手相分析';

  @override
  String get historyEmpty => 'まだ保存された分析がありません';

  @override
  String get historyLoginPrompt => 'ログイン後に分析履歴を確認できます';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get deleteRecord => '履歴削除';

  @override
  String get deleteRecordContent =>
      'この分析履歴を削除しますか？\n関連する相談履歴も一緒に削除されます。\n削除したデータは復元できません。';

  @override
  String get deleteFailed => '削除失敗';

  @override
  String get cacheDeleteConfirm => 'アプリキャッシュを削除しますか？';

  @override
  String cacheDeleteSuccess(String mb) {
    return 'キャッシュを削除しました（${mb}MB）';
  }

  @override
  String get cacheDeleteFailed => 'キャッシュの削除に失敗しました';

  @override
  String get loginRequired => 'ログインが必要';

  @override
  String get loginRequiredContent => '保存するにはログインが必要です。\nログイン後に自動的に保存されます。';

  @override
  String saveSuccess(String name) {
    return '$nameさんの結果が保存されました';
  }

  @override
  String get saveFailed => '保存に失敗しました。もう一度お試しください。';

  @override
  String get palmViewResults => '手相結果を見る';

  @override
  String get cameraPermissionRequired => 'カメラの許可が必要です';

  @override
  String get facePermissionDesc => '顔分析のためカメラアクセスを許可してください';

  @override
  String get palmPermissionDesc => '手相分析のためカメラアクセスを許可してください';

  @override
  String get openSettings => '設定で許可する';

  @override
  String get goBack => '戻る';

  @override
  String get palmGuide => '手のひらを画面に\n向けて広げてください';

  @override
  String get aiEngineInitializing => 'AIエンジンを初期化中...';

  @override
  String get faceAnalyzing => '観相分析中...';

  @override
  String get palmAnalyzing => '手相分析中...';

  @override
  String get faceAnalysisResult => '観相分析結果';

  @override
  String get palmAnalysisResult => '手相分析結果';

  @override
  String get analysisError => '分析中にエラーが発生しました';

  @override
  String get aiModelError => 'AIモデルエラー';

  @override
  String get modelReinstall => 'モデルを再インストール';

  @override
  String get consultationCreateFailed => '相談の作成に失敗しました';

  @override
  String get sectionLifeline => '生命線';

  @override
  String get sectionHeartline => '感情線';

  @override
  String get sectionHeadline => '頭脳線';

  @override
  String get sectionFateline => '運命線';

  @override
  String get sectionHandshape => '手の形';

  @override
  String palmResultTitle(String hand) {
    return '$hand手相分析';
  }

  @override
  String get consultationTitle => '相談';

  @override
  String get consultationNotFound => '相談が見つかりません';

  @override
  String get backToList => '一覧へ';

  @override
  String get consultationDeleteContent => 'この相談を削除しますか？\n全ての会話が消えます。';

  @override
  String get consultationTitleHint => '相談タイトル';

  @override
  String get consultationEmptyHint => '分析結果について気になることを聞いてください';

  @override
  String get faceConsultation => '観相相談';

  @override
  String get palmConsultation => '手相相談';

  @override
  String get pickerEmptyFace => '保存された観相分析がありません';

  @override
  String get pickerEmptyPalm => '保存された手相分析がありません';

  @override
  String get chatGenerating => '応答を生成中...';

  @override
  String get copied => 'コピーしました';

  @override
  String get modelScanning => 'デバイスを確認中...';

  @override
  String get modelScanningDesc => 'インストールされたAIモデルを探しています';

  @override
  String get modelFound => 'モデルを発見！';

  @override
  String modelDownloadingWith(String name) {
    return 'AIモデル準備中 ($name)';
  }

  @override
  String modelDownloadDescWithSize(String size) {
    return '初回のみダウンロードします（約${size}GB）';
  }

  @override
  String get downloadFailed => 'ダウンロード失敗';

  @override
  String get errorPrefix => 'エラー';

  @override
  String get agreePrefix => '同意します：';

  @override
  String get agreeConnector => 'および';

  @override
  String get subjectPickerTitle => '誰の分析ですか？';

  @override
  String get subjectPickerSubtitle => '分析結果を保存する対象を選択してください';

  @override
  String get subjectPickerCustom => 'カスタム入力';

  @override
  String get subjectPickerCustomHint => '名前または関係を入力してください';

  @override
  String get subjectPickerConfirm => '保存する';

  @override
  String get subjectMe => '自分';

  @override
  String get subjectSpouse => '配偶者';

  @override
  String get subjectFriend => '友達';

  @override
  String get subjectParents => '親';

  @override
  String get subjectChild => '子供';

  @override
  String get subjectSibling => '兄弟/姉妹';

  @override
  String get justNow => 'たった今';

  @override
  String minutesAgo(int count) {
    return '$count分前';
  }

  @override
  String hoursAgo(int count) {
    return '$count時間前';
  }

  @override
  String daysAgo(int count) {
    return '$count日前';
  }

  @override
  String get homeGreeting => '今日のアウラ';

  @override
  String get homeDailyFallback => '今日もあなたの佇まいが曇りませんように。';

  @override
  String get homeFaceLabel => 'AI 人相';

  @override
  String get homeFaceTitle => '顔を読む';

  @override
  String get homeFaceDesc => '468 ランドマーク';

  @override
  String get homePalmLabel => 'AI 手相';

  @override
  String get homePalmTitle => '手を読む';

  @override
  String get homePalmDesc => '21 ランドマーク';

  @override
  String get homeResumeTitle => '続きから';

  @override
  String get homeResumeEmpty => '進行中の相談はまだありません。';

  @override
  String get commonSeeAll => 'すべて見る';

  @override
  String get commonGuest => 'ゲスト';

  @override
  String get commonShare => '共有';

  @override
  String get commonSave => '保存';

  @override
  String get commonCopied => 'コピーしました';

  @override
  String get commonLoadError => '読み込めませんでした';

  @override
  String get historyTitle => '履歴';

  @override
  String get historyAll => 'すべて';

  @override
  String get historyFace => '人相';

  @override
  String get historyPalm => '手相';

  @override
  String get settingsTitle => '設定';

  @override
  String get faceResultTitle => '人相レポート';

  @override
  String faceResultAnalyzedAt(String time) {
    return '$time 解析';
  }

  @override
  String get faceResultStreamingTitle => '解析中です';

  @override
  String get faceResultReadyTitle => 'レポートが完成しました';

  @override
  String get resultConsult => 'Auraに相談する';

  @override
  String get consultationsTitle => '相談';

  @override
  String get consultationAuraTitle => 'Aura';

  @override
  String get consultationSubjectYou => 'あなたの解析に基づく';

  @override
  String get consultationContextTitle => '解析コンテキスト';

  @override
  String get consultationComposerHint => 'Auraに聞く…';

  @override
  String get consultationEmptyTitle => 'まだ相談がありません';

  @override
  String get consultationEmptyBody => 'レポートを開いて気になる点を聞いてみましょう。';

  @override
  String get consultationStart => '新しい相談を始める';

  @override
  String get authTagline => '顔と手で読む AI 人相・手相';

  @override
  String get authAgreeTerms => '利用規約に同意します';

  @override
  String get authAgreePrivacy => 'プライバシーポリシーに同意します';

  @override
  String get authSignInGoogle => 'Googleで続ける';

  @override
  String get authSignInApple => 'Appleで続ける';

  @override
  String get authContinueGuest => 'ゲストとして試す';

  @override
  String get settingsSectionAnalysis => '解析';

  @override
  String get settingsSectionPrivacy => 'プライバシー・法的';

  @override
  String get settingsSectionAbout => 'アプリ情報';
}
