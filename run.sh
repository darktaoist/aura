#!/bin/bash
# Aura 앱 실행 단축 스크립트
# 사용: ./run.sh [device-id]
# 예:   ./run.sh                    # 연결된 기기 자동 선택
#       ./run.sh LMQ920N68d99036    # 특정 기기 지정

SUPABASE_URL="https://vpjfwwijijjevjmudjol.supabase.co"
SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZwamZ3d2lqaWpqZXZqbXVkam9sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU5NjA1MjEsImV4cCI6MjA5MTUzNjUyMX0.W0xd9p85e2oAxhZwKcsWXxEXKfWYRZZsNz-3WNILFOE"

DEVICE_FLAG=""
if [ -n "$1" ]; then
  DEVICE_FLAG="-d $1"
fi

flutter run $DEVICE_FLAG \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
