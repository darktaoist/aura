import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../home/widgets/aura_wordmark.dart';
import 'model_config.dart';
import 'model_selector.dart';

/// 첫 실행 시 자동으로 Gemma 모델 다운로드
/// 사용자는 그냥 기다리기만 하면 됨
class ModelSetupScreen extends StatefulWidget {
  const ModelSetupScreen({super.key, required this.onComplete});
  final VoidCallback onComplete;

  @override
  State<ModelSetupScreen> createState() => _ModelSetupScreenState();
}

class _ModelSetupScreenState extends State<ModelSetupScreen> {
  _Phase _phase = _Phase.scanning;
  int _downloadProgress = 0;
  String? _errorMsg;
  String? _foundLocalPath;
  GemmaModelConfig _model = kDefaultModel; // selectModel()로 교체됨

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    // 모델 선택을 스캔과 병렬로 실행
    final results = await Future.wait([
      _scanLocal(),
      selectModel(),
    ]);
    final localPath = results[0] as String?;
    _model = results[1] as GemmaModelConfig;
    debugPrint('[ModelSetupScreen] 선택된 모델: ${_model.name}');

    if (localPath != null) {
      setState(() {
        _foundLocalPath = localPath;
        _phase = _Phase.registering;
      });
      await _registerFile(localPath);
    } else {
      setState(() => _phase = _Phase.downloading);
      await _download(_model);
    }
  }

  Future<String?> _scanLocal() async {
    final dirs = await buildScanDirs();
    for (final dir in dirs) {
      try {
        final d = Directory(dir);
        if (!d.existsSync()) continue;
        for (final e in d.listSync(followLinks: false)) {
          if (e is File) {
            final lower = e.path.toLowerCase();
            if (kModelExtensions.any(lower.endsWith)) {
              return e.path;
            }
          }
        }
      } catch (_) {}
    }
    return null;
  }

  Future<void> _registerFile(String path) async {
    try {
      final config = configForFile(path);
      if (mounted) setState(() => _phase = _Phase.installing);
      await FlutterGemma.installModel(
        modelType: config.modelType,
        fileType: config.fileType,
      ).fromFile(path).install();

      if (mounted) widget.onComplete();
    } catch (e) {
      setState(() => _phase = _Phase.downloading);
      await _download(_model);
    }
  }

  /// Range 요청 기반 재개 다운로드 + SHA-256 검증.
  ///
  /// [attempt] 0: 최초 시도, 1: 해시 불일치 후 재시도 (최대 1회).
  Future<void> _download(GemmaModelConfig model, {int attempt = 0}) async {
    String? savePath;
    try {
      final appDoc = await getApplicationDocumentsDirectory();
      savePath = '${appDoc.path}/${model.fileName}';

      final file = File(savePath);
      final existingSize = file.existsSync() ? file.lengthSync() : 0;

      final dio = Dio();
      final headers = <String, dynamic>{
        'User-Agent': 'Mozilla/5.0 (Android)',
        if (existingSize > 0) 'Range': 'bytes=$existingSize-',
      };

      final resp = await dio.get<ResponseBody>(
        model.downloadUrl,
        options: Options(
          responseType: ResponseType.stream,
          headers: headers,
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (s) => s != null && s < 400,
        ),
      );

      final isPartial = resp.statusCode == 206;
      final contentLength = int.tryParse(
        resp.headers.value(Headers.contentLengthHeader) ?? '',
      ) ?? 0;

      final startFrom = isPartial ? existingSize : 0;
      final total = contentLength > 0 ? startFrom + contentLength : model.expectedBytes;
      int received = startFrom;

      final raf = await file.open(
        mode: isPartial ? FileMode.append : FileMode.write,
      );

      try {
        await for (final chunk in resp.data!.stream) {
          await raf.writeFrom(chunk);
          received += chunk.length;
          if (total > 0 && mounted) {
            setState(() => _downloadProgress = (received / total * 100).clamp(0, 100).round());
          }
        }
      } finally {
        await raf.close();
      }

      // 파일 크기 검증
      if (!await isValidModelContent(file, expectedBytes: model.expectedBytes)) {
        await file.delete();
        throw Exception('다운로드된 파일이 유효하지 않습니다 (크기 부족).');
      }

      // SHA-256 검증 (수십 초 소요 — 별도 단계로 표시)
      if (mounted) setState(() => _phase = _Phase.verifying);
      final hashOk = await _verifySha256(file, model);
      if (!hashOk) {
        await file.delete();
        if (attempt == 0) {
          debugPrint('[Download] 해시 불일치 → 재시도');
          if (mounted) setState(() {
            _phase = _Phase.downloading;
            _downloadProgress = 0;
          });
          await _download(model, attempt: 1);
          return;
        }
        throw Exception('파일 무결성 검증 실패 (SHA-256 불일치). 저장공간을 확인하세요.');
      }

      // 검증 통과 → 등록
      if (mounted) setState(() => _phase = _Phase.installing);
      await FlutterGemma.installModel(
        modelType: model.modelType,
        fileType: model.fileType,
      ).fromFile(savePath).install();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('model_url_version', kModelUrlVersion);

      if (mounted) widget.onComplete();
    } catch (e) {
      if (savePath != null) {
        try { await File(savePath).delete(); } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _phase = _Phase.error;
          _errorMsg = e.toString();
        });
      }
    }
  }

  /// .sha256 파일을 받아 로컬 파일과 비교한다.
  ///
  /// .sha256 파일을 받을 수 없으면 true를 반환해 다운로드를 계속 진행한다.
  Future<bool> _verifySha256(File file, GemmaModelConfig model) async {
    try {
      final dio = Dio();
      final resp = await dio.get<String>(
        model.sha256Url,
        options: Options(
          responseType: ResponseType.plain,
          validateStatus: (s) => s != null && s < 400,
        ),
      );
      final expectedHash = (resp.data ?? '')
          .trim()
          .split(RegExp(r'\s+'))
          .first
          .toLowerCase();

      if (expectedHash.isEmpty || expectedHash.length != 64) {
        debugPrint('[Download] .sha256 파일 형식 불명 → 검증 스킵');
        return true;
      }

      // 64 MB 청크 단위로 해시 계산 (메모리 효율)
      Digest? digest;
      final input = sha256.startChunkedConversion(
        ChunkedConversionSink.withCallback((chunks) => digest = chunks.single),
      );
      final raf = await file.open();
      try {
        const chunkSize = 64 * 1024 * 1024;
        while (true) {
          final chunk = await raf.read(chunkSize);
          if (chunk.isEmpty) break;
          input.add(chunk);
        }
      } finally {
        await raf.close();
      }
      input.close();
      final actualHash = digest!.toString();

      if (expectedHash != actualHash) {
        debugPrint('[Download] SHA-256 불일치: expected=$expectedHash actual=$actualHash');
        return false;
      }
      debugPrint('[Download] SHA-256 검증 완료: $actualHash');
      return true;
    } catch (e) {
      debugPrint('[Download] SHA-256 검증 오류 (스킵): $e');
      return true; // 네트워크 오류 등은 무시하고 진행
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aura = context.auraColors;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.6),
                    radius: 1.0,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AuraWordmark(size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'AI 관상·손금',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: aura.onSurfaceMuted),
                  ),
                  const SizedBox(height: 48),
                  _buildBody(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final aura = context.auraColors;
    final cs = theme.colorScheme;

    switch (_phase) {
      case _Phase.scanning:
        return _StatusTile(
          icon: Icons.search,
          title: l10n.modelScanning,
          subtitle: l10n.modelScanningDesc,
          showSpinner: true,
        );

      case _Phase.registering:
        return _StatusTile(
          icon: Icons.check_circle_outline,
          title: l10n.modelFound,
          subtitle: _foundLocalPath!.split('/').last,
          showSpinner: true,
        );

      case _Phase.downloading:
        final sizeGb = _model.sizeGb;
        final downloaded =
            (_downloadProgress / 100 * sizeGb).toStringAsFixed(1);
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: aura.surfaceContainer,
            border: Border.all(color: aura.cardBorder, width: 1),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusTile(
                icon: Icons.download_rounded,
                title: l10n.modelDownloadingWith(_model.name),
                subtitle: l10n.modelDownloadDescWithSize(sizeGb.toString()),
                showSpinner: false,
              ),
              const SizedBox(height: AppSpacing.lg),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  value: _downloadProgress / 100,
                  minHeight: 6,
                  backgroundColor: aura.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$downloaded GB / $sizeGb GB',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: aura.onSurfaceMuted)),
                  Text('$_downloadProgress%',
                      style: theme.textTheme.labelMedium?.copyWith(
                          color: cs.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        );

      case _Phase.verifying:
        return _StatusTile(
          icon: Icons.verified_outlined,
          title: l10n.modelVerifying,
          subtitle: l10n.modelVerifyingDesc,
          showSpinner: true,
        );

      case _Phase.installing:
        return _StatusTile(
          icon: Icons.install_mobile_outlined,
          title: l10n.modelInstalling,
          subtitle: l10n.modelInstallingDesc,
          showSpinner: true,
        );

      case _Phase.error:
        return Column(
          children: [
            Icon(Icons.error_outline, color: AppColors.danger, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.downloadFailed,
                style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(_errorMsg ?? '',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: aura.onSurfaceMuted),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _phase = _Phase.scanning;
                  _downloadProgress = 0;
                  _errorMsg = null;
                });
                _start();
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        );
    }
  }
}

enum _Phase { scanning, registering, downloading, verifying, installing, error }

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.showSpinner,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aura = context.auraColors;

    return Row(
      children: [
        if (showSpinner)
          SizedBox(
            width: 22, height: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: theme.colorScheme.primary),
          )
        else
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.seed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.seed, size: 20),
          ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: aura.onSurfaceMuted),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}
