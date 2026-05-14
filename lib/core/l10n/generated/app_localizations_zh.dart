// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Aura';

  @override
  String get faceReading => '面相';

  @override
  String get palmReading => '手相';

  @override
  String get faceReadingDesc => '通过面部特征读取命运';

  @override
  String get palmReadingDesc => '通过手掌纹路预测未来';

  @override
  String get settings => '设置';

  @override
  String get history => '历史记录';

  @override
  String get loginBanner => '登录后可保存分析结果';

  @override
  String get loginPrompt => '请登录以保存结果';

  @override
  String get loginWithGoogle => '使用Google登录';

  @override
  String get loginWithKakao => '使用Kakao登录';

  @override
  String get skip => '跳过';

  @override
  String get agreeTerms => '我同意服务条款和隐私政策';

  @override
  String get viewResults => '查看面相结果';

  @override
  String get analyzing => '分析中...';

  @override
  String get faceDetected => '检测到面部';

  @override
  String get stabilizing => '稳定中...';

  @override
  String get stabilityDone => '特征点提取完成';

  @override
  String get cameraGuideAlign => '请将脸部对准画面';

  @override
  String get cameraGuideAlignHand => '请将手掌放入画面内';

  @override
  String get cameraGuideScanning => '识别中，请稍候';

  @override
  String get cameraGuideDone => '完成！请点击下方按钮';

  @override
  String get retry => '重新分析';

  @override
  String get save => '保存';

  @override
  String get share => '分享';

  @override
  String get sectionForehead => '额头';

  @override
  String get sectionEyes => '眼睛';

  @override
  String get sectionNose => '鼻子';

  @override
  String get sectionMouth => '嘴巴';

  @override
  String get sectionChin => '下巴';

  @override
  String get sectionOverall => '综合';

  @override
  String get modelDownloading => 'AI模型准备中';

  @override
  String get modelDownloadDesc => '仅需下载一次';

  @override
  String get modelReady => 'AI模型已准备好';

  @override
  String get themeLight => '浅色模式';

  @override
  String get themeDark => '深色模式';

  @override
  String get language => '语言';

  @override
  String get model => 'AI模型';

  @override
  String get clearCache => '清除缓存';

  @override
  String get logout => '退出登录';

  @override
  String get deleteAccount => '注销账户';

  @override
  String get version => '版本';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get termsOfService => '服务条款';

  @override
  String get leftHand => '左手';

  @override
  String get rightHand => '右手';

  @override
  String get mainConsultation => '继续咨询';

  @override
  String get mainConsultationSubtitle => '深入了解您的分析结果';

  @override
  String get mainConsultationLoginRequired => '需要登录';

  @override
  String get consultationListTitle => '咨询记录';

  @override
  String get consultationListEmpty => '暂无咨询记录';

  @override
  String get consultationListEmptyAction => '从面相或手相分析开始';

  @override
  String get consultationListNew => '新咨询';

  @override
  String get consultationDeleteConfirm => '删除此咨询？';

  @override
  String consultationMessageCount(int count) {
    return '$count条消息';
  }

  @override
  String get pickerTitle => '选择分析';

  @override
  String get pickerTabFace => '面相';

  @override
  String get pickerTabPalm => '手相';

  @override
  String get pickerEmpty => '没有已保存的分析结果';

  @override
  String get pickerEmptyAction => '开始分析';

  @override
  String get chatInputHint => '请输入您的问题';

  @override
  String get chatTitleEdit => '编辑标题';

  @override
  String get chatDeleteConsultation => '删除咨询';

  @override
  String get chatErrorGeneration => '生成回复失败，请重试。';

  @override
  String get resultStartConsultation => '开始咨询';

  @override
  String get resultSaveBeforeConsult => '请先保存结果';

  @override
  String get resultLoginToConsult => '咨询需要登录';

  @override
  String get todayReading => '今日分析';

  @override
  String get login => '登录';

  @override
  String get theme => '主题';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get languageSelect => '选择语言';

  @override
  String get faceAnalysis => '面相分析';

  @override
  String get palmAnalysis => '手相分析';

  @override
  String get historyEmpty => '暂无保存的分析';

  @override
  String get historyLoginPrompt => '登录后查看分析历史';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get deleteRecord => '删除记录';

  @override
  String get deleteRecordContent => '确定删除此分析记录？\n相关咨询记录也将一并删除。\n删除后无法恢复。';

  @override
  String get deleteFailed => '删除失败';

  @override
  String get cacheDeleteConfirm => '清除应用缓存？';

  @override
  String cacheDeleteSuccess(String mb) {
    return '缓存已清除（${mb}MB）';
  }

  @override
  String get cacheDeleteFailed => '清除缓存失败';

  @override
  String get loginRequired => '需要登录';

  @override
  String get loginRequiredContent => '保存需要登录。\n登录后将自动保存。';

  @override
  String saveSuccess(String name) {
    return '已保存$name的结果';
  }

  @override
  String get saveFailed => '保存失败，请重试。';

  @override
  String get palmViewResults => '查看手相结果';

  @override
  String get cameraPermissionRequired => '需要相机权限';

  @override
  String get facePermissionDesc => '请允许相机访问以进行面相分析';

  @override
  String get palmPermissionDesc => '请允许相机访问以进行手相分析';

  @override
  String get openSettings => '在设置中允许';

  @override
  String get goBack => '返回';

  @override
  String get palmGuide => '请将手掌朝向\n屏幕展开';

  @override
  String get aiEngineInitializing => 'AI引擎初始化中...';

  @override
  String get aiEngineInitializingDesc => '首次运行可能需要几秒钟';

  @override
  String get aiEngineInitError => 'AI引擎初始化失败';

  @override
  String get aiEngineRetry => '重试';

  @override
  String get faceAnalyzing => '面相分析中...';

  @override
  String get palmAnalyzing => '手相分析中...';

  @override
  String get faceAnalysisResult => '面相分析结果';

  @override
  String get palmAnalysisResult => '手相分析结果';

  @override
  String get analysisError => '分析过程中发生错误';

  @override
  String get aiModelError => 'AI模型错误';

  @override
  String get modelReinstall => '重新安装模型';

  @override
  String get consultationCreateFailed => '创建咨询失败';

  @override
  String get sectionLifeline => '生命线';

  @override
  String get sectionHeartline => '感情线';

  @override
  String get sectionHeadline => '头脑线';

  @override
  String get sectionFateline => '命运线';

  @override
  String get sectionHandshape => '手形';

  @override
  String palmResultTitle(String hand) {
    return '$hand手相分析';
  }

  @override
  String get consultationTitle => '咨询';

  @override
  String get consultationNotFound => '找不到咨询';

  @override
  String get backToList => '返回列表';

  @override
  String get consultationDeleteContent => '删除此咨询？\n所有消息将被删除。';

  @override
  String get consultationTitleHint => '咨询标题';

  @override
  String get consultationEmptyHint => '请提问关于分析结果的问题';

  @override
  String get faceConsultation => '面相咨询';

  @override
  String get palmConsultation => '手相咨询';

  @override
  String get pickerEmptyFace => '没有保存的面相分析';

  @override
  String get pickerEmptyPalm => '没有保存的手相分析';

  @override
  String get chatGenerating => '正在生成回复...';

  @override
  String get copied => '已复制';

  @override
  String get modelScanning => '扫描设备中...';

  @override
  String get modelScanningDesc => '正在搜索已安装的AI模型';

  @override
  String get modelFound => '发现模型！';

  @override
  String get modelVerifying => '正在验证文件完整性...';

  @override
  String get modelVerifyingDesc => '正在检查下载的文件（可能需要一些时间）';

  @override
  String get modelInstalling => '正在安装模型...';

  @override
  String get modelInstallingDesc => '正在将AI模型注册到应用程序';

  @override
  String modelDownloadingWith(String name) {
    return 'AI模型准备中 ($name)';
  }

  @override
  String modelDownloadDescWithSize(String size) {
    return '仅需下载一次（约${size}GB）';
  }

  @override
  String get downloadFailed => '下载失败';

  @override
  String get errorPrefix => '错误';

  @override
  String get agreePrefix => '我同意：';

  @override
  String get agreeConnector => '和';

  @override
  String get subjectPickerTitle => '这是谁的分析？';

  @override
  String get subjectPickerSubtitle => '请选择保存分析结果的对象';

  @override
  String get subjectPickerCustom => '自定义输入';

  @override
  String get subjectPickerCustomHint => '输入姓名或关系';

  @override
  String get subjectPickerConfirm => '保存';

  @override
  String get subjectMe => '我';

  @override
  String get subjectSpouse => '配偶';

  @override
  String get subjectFriend => '朋友';

  @override
  String get subjectParents => '父母';

  @override
  String get subjectChild => '子女';

  @override
  String get subjectSibling => '兄弟/姐妹';

  @override
  String get justNow => '刚才';

  @override
  String minutesAgo(int count) {
    return '$count分钟前';
  }

  @override
  String hoursAgo(int count) {
    return '$count小时前';
  }

  @override
  String daysAgo(int count) {
    return '$count天前';
  }

  @override
  String get homeGreeting => '今日气场';

  @override
  String get homeDailyFallback => '愿你今日气息清晰、心神安稳。';

  @override
  String get homeFaceLabel => 'AI 面相';

  @override
  String get homeFaceTitle => '读面';

  @override
  String get homeFaceDesc => 'AI解析468个面部特征点，从额头到下巴全面解读您的面相';

  @override
  String get homePalmLabel => 'AI 手相';

  @override
  String get homePalmTitle => '读手';

  @override
  String get homePalmDesc => 'AI通过21个手部特征点解读生命线、感情线、头脑线与命运线';

  @override
  String get homeResumeTitle => '继续未完';

  @override
  String get homeResumeEmpty => '暂无进行中的咨询。';

  @override
  String get commonSeeAll => '查看全部';

  @override
  String get commonGuest => '访客';

  @override
  String get commonShare => '分享';

  @override
  String get commonSave => '保存';

  @override
  String get commonCopied => '已复制';

  @override
  String get commonLoadError => '加载失败';

  @override
  String get historyTitle => '记录';

  @override
  String get historyAll => '全部';

  @override
  String get historyFace => '面相';

  @override
  String get historyPalm => '手相';

  @override
  String get settingsTitle => '设置';

  @override
  String get faceResultTitle => '面相报告';

  @override
  String faceResultAnalyzedAt(String time) {
    return '$time 分析';
  }

  @override
  String get faceResultStreamingTitle => '正在为您生成报告';

  @override
  String get faceResultReadyTitle => '报告已完成';

  @override
  String get resultConsult => '向 Aura 咨询';

  @override
  String get consultationsTitle => '咨询';

  @override
  String get consultationAuraTitle => 'Aura';

  @override
  String get consultationSubjectYou => '基于你的分析';

  @override
  String get consultationContextTitle => '分析上下文';

  @override
  String get consultationComposerHint => '向 Aura 提问…';

  @override
  String get consultationEmptyTitle => '还没有咨询';

  @override
  String get consultationEmptyBody => '打开一份报告,问问你想知道的。';

  @override
  String get consultationStart => '开始新咨询';

  @override
  String get authTagline => '用面与手读你的 AI 面相·手相';

  @override
  String get authAgreeTerms => '我同意用户协议';

  @override
  String get authAgreePrivacy => '我同意隐私政策';

  @override
  String get authSignInGoogle => '使用 Google 继续';

  @override
  String get authSignInApple => '使用 Apple 继续';

  @override
  String get authContinueGuest => '以访客身份浏览';

  @override
  String get settingsSectionAnalysis => '分析';

  @override
  String get settingsSectionPrivacy => '隐私与法律';

  @override
  String get settingsSectionAbout => '关于应用';

  @override
  String get streamingBackTitle => '正在分析中';

  @override
  String get streamingBackBody => 'AI分析尚未完成。\n现在退出可能会导致下次分析延迟启动。';

  @override
  String get streamingBackLeave => '退出';

  @override
  String get selectFromGallery => '从相册选择';

  @override
  String get noFaceDetected => '未检测到人脸，请选择其他照片。';

  @override
  String get noPalmDetected => '未检测到手部，请选择其他照片。';

  @override
  String get galleryPermissionRequired => '需要相册访问权限。';

  @override
  String get streakDays => '天连续';

  @override
  String get todayBadge => '今日';

  @override
  String get minRead => '3 MIN';

  @override
  String get aiName => '타오운세';

  @override
  String get homeConsultLabel => 'AI咨询';

  @override
  String get homeConsultSub => '基于分析结果进行深度对话';

  @override
  String get selectLanguageTitle => '请选择语言';

  @override
  String get selectLanguageSub => 'SELECT YOUR LANGUAGE';

  @override
  String get enterApp => '进入 →';

  @override
  String get confidence => '可信度';

  @override
  String get authSignInSubtitle => '登录后可保存分析结果并继续AI咨询';

  @override
  String get authTermsNotice => '登录即表示您同意我们的服务条款和隐私政策。';
}
