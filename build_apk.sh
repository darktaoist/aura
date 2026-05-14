#!/bin/bash
cd ~/works/gwansang
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://vpjfwwijijjevjmudjol.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZwamZ3d2lqaWpqZXZqbXVkam9sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU5NjA1MjEsImV4cCI6MjA5MTUzNjUyMX0.W0xd9p85e2oAxhZwKcsWXxEXKfWYRZZsNz-3WNILFOE

if [ $? -eq 0 ]; then
  mv build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/aura.apk
  echo "✅ 빌드 완료: build/app/outputs/flutter-apk/aura.apk"
else
  echo "❌ 빌드 실패"
fi
