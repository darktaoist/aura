import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model_config.dart';

const _kPrefModelKey = 'selected_model';

/// E4B 비활성화 플래그. true면 RAM과 무관하게 항상 E2B를 사용한다.
const _kForceE2B = true;

/// RAM 기반으로 최적 모델을 자동 선택한다.
///
/// SharedPreferences에 수동 설정값이 있으면 자동 감지보다 우선한다.
/// 임계값: 보고된 RAM 7 GB 이상(물리 8 GB 기기) → E4B, 그 외 → E2B.
Future<GemmaModelConfig> selectModel() async {
  if (_kForceE2B) {
    debugPrint('[ModelSelector] E2B 강제 모드');
    return kGemmaE2B;
  }

  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_kPrefModelKey);

  if (saved == 'E4B') return kGemmaE4B;
  if (saved == 'E2B') return kGemmaE2B;

  // 수동 설정 없음 → RAM 자동 감지
  final ramMb = await _getTotalRamMb();
  debugPrint('[ModelSelector] 총 RAM: $ramMb MB');

  final model = ramMb >= 7000 ? kGemmaE4B : kGemmaE2B;
  debugPrint('[ModelSelector] 선택된 모델: ${model.name}');

  // 자동 감지 결과를 저장해 두면 다음 실행 시 재감지 불필요
  await prefs.setString(_kPrefModelKey, model == kGemmaE4B ? 'E4B' : 'E2B');
  return model;
}

/// 설정 화면에서 모델을 수동으로 변경할 때 사용한다.
/// 저장 후 앱을 재시작(또는 model_setup 재진입)해야 적용된다.
Future<void> setPreferredModel(GemmaModelConfig model) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kPrefModelKey, model == kGemmaE4B ? 'E4B' : 'E2B');
}

/// /proc/meminfo 에서 MemTotal(kB)을 읽어 MB로 환산한다.
/// Android 전용. 읽기 실패 시 0 반환.
Future<int> _getTotalRamMb() async {
  if (!Platform.isAndroid) return 0;
  try {
    final lines = await File('/proc/meminfo').readAsLines();
    for (final line in lines) {
      if (line.startsWith('MemTotal:')) {
        final parts = line.trim().split(RegExp(r'\s+'));
        final kb = int.tryParse(parts[1]) ?? 0;
        return kb ~/ 1024;
      }
    }
  } catch (e) {
    debugPrint('[ModelSelector] /proc/meminfo 읽기 오류: $e');
  }
  return 0;
}
