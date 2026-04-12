import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

import 'model_config.dart';

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
  String? _foundLocalPath; // 로컬에서 발견된 파일

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    // 1. 먼저 기기에 이미 있는 파일 스캔
    final localPath = await _scanLocal();

    if (localPath != null) {
      // 로컬 파일로 바로 등록
      setState(() {
        _foundLocalPath = localPath;
        _phase = _Phase.registering;
      });
      await _registerFile(localPath);
    } else {
      // 없으면 자동 다운로드
      setState(() => _phase = _Phase.downloading);
      await _download();
    }
  }

  Future<String?> _scanLocal() async {
    for (final dir in kScanDirs) {
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
      await FlutterGemma.installModel(
        modelType: config.modelType,
        fileType: config.fileType,
      ).fromFile(path).install();

      if (mounted) widget.onComplete();
    } catch (e) {
      // 로컬 파일 등록 실패 → 다운로드로 폴백
      setState(() => _phase = _Phase.downloading);
      await _download();
    }
  }

  Future<void> _download() async {
    try {
      await FlutterGemma.installModel(
        modelType: kDefaultModel.modelType,
        fileType: kDefaultModel.fileType,
      )
          .fromNetwork(kDefaultModel.downloadUrl)
          .withProgress((p) {
            if (mounted) setState(() => _downloadProgress = p);
          })
          .install();

      if (mounted) widget.onComplete();
    } catch (e) {
      if (mounted) {
        setState(() {
          _phase = _Phase.error;
          _errorMsg = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.face_retouching_natural,
                  size: 72, color: Colors.indigoAccent),
              const SizedBox(height: 24),
              const Text(
                '관상 AI',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 48),
              _buildBody(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_phase) {
      case _Phase.scanning:
        return _StatusTile(
          icon: Icons.search,
          title: '기기 확인 중...',
          subtitle: '설치된 AI 모델을 찾고 있습니다',
          showSpinner: true,
        );

      case _Phase.registering:
        return _StatusTile(
          icon: Icons.check_circle_outline,
          title: '모델 발견!',
          subtitle: _foundLocalPath!.split('/').last,
          showSpinner: true,
        );

      case _Phase.downloading:
        final sizeGb = kDefaultModel.sizeGb;
        final downloaded = (_downloadProgress / 100 * sizeGb).toStringAsFixed(1);
        return Column(
          children: [
            _StatusTile(
              icon: Icons.download_rounded,
              title: 'AI 모델 준비 중',
              subtitle: '처음 한 번만 다운로드합니다 (약 ${sizeGb}GB)',
              showSpinner: false,
            ),
            const SizedBox(height: 28),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _downloadProgress / 100,
                minHeight: 10,
                backgroundColor: Colors.white12,
                valueColor:
                    const AlwaysStoppedAnimation(Colors.indigoAccent),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$downloaded GB / ${kDefaultModel.sizeGb} GB',
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                Text(
                  '$_downloadProgress%',
                  style: const TextStyle(
                      color: Colors.indigoAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ],
            ),
          ],
        );

      case _Phase.error:
        return Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            const SizedBox(height: 12),
            Text(
              '다운로드 실패',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMsg ?? '',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _phase = _Phase.scanning;
                  _downloadProgress = 0;
                  _errorMsg = null;
                });
                _start();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
    }
  }
}

enum _Phase { scanning, registering, downloading, error }

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showSpinner)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Colors.indigoAccent),
          )
        else
          Icon(icon, color: Colors.indigoAccent, size: 20),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle,
                style:
                    const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
