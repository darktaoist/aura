# Phase 12 — pipeline-designer + infra-engineer 산출물
> CI/CD 파이프라인 · 빌드 설정
> 날짜: 2026-04-12

---

## 1. GitHub Actions 파이프라인

파일: `.github/workflows/ci.yml`

### 스테이지

```
push/PR
  └─ analyze_and_test
      ├─ flutter pub get
      ├─ build_runner (코드 생성)
      ├─ flutter gen-l10n
      ├─ flutter analyze --fatal-infos
      ├─ flutter test --coverage
      └─ codecov 업로드
         (main 브랜치만)
  └─ build_apk
      ├─ flutter build apk --release
      │   --dart-define=SUPABASE_URL
      │   --dart-define=SUPABASE_ANON_KEY
      └─ artifact 업로드 (7일 보관)
```

---

## 2. 빌드 실행 명령 (로컬)

```bash
# 의존성 설치
flutter pub get

# 코드 생성 (freezed, riverpod_generator, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# 다국어 생성
flutter gen-l10n

# 분석
flutter analyze

# 테스트
flutter test

# APK 빌드
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...
```

---

## 3. Secrets 설정 (GitHub)

| Secret 이름 | 값 |
|---|---|
| `SUPABASE_URL` | `https://{project}.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase anon public key |

> Settings → Secrets and variables → Actions → New repository secret

---

## 4. 브랜치 전략

```
main      ← production (APK 빌드 트리거)
develop   ← 개발 통합
feature/* ← 기능 개발 (PR → develop)
```

---

*Phase 12 완료: 2026-04-12*
