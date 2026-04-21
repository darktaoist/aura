-- =============================================================================
-- Migration: 20260421000001_consultation_chat.sql
-- 대상 프로젝트: Aura (gwansang) — Supabase
-- 적용 방법: Supabase 대시보드 > SQL Editor 에 붙여넣고 실행
--            또는 Supabase CLI: supabase db push
-- 전제 조건: 20260412000003_readings.sql (public.readings 테이블) 이 먼저 적용되어 있어야 함
-- =============================================================================

-- 상담 세션 테이블
CREATE TABLE public.consultations (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  analysis_type    TEXT        NOT NULL CHECK (analysis_type IN ('face', 'palm')),
  analysis_id      UUID        NOT NULL REFERENCES public.readings(id) ON DELETE SET NULL,
  context_summary  TEXT        NOT NULL,
  context_features JSONB       NOT NULL DEFAULT '{}',
  title            TEXT,
  locale           TEXT        NOT NULL DEFAULT 'ko',
  model_used       TEXT        NOT NULL CHECK (model_used IN ('E2B', 'E4B')),
  message_count    INT         NOT NULL DEFAULT 0,
  last_message_at  TIMESTAMPTZ          DEFAULT NOW(),
  created_at       TIMESTAMPTZ          DEFAULT NOW()
);

COMMENT ON TABLE  public.consultations                  IS '관상/손금 분석 결과를 기반으로 한 AI 상담 세션';
COMMENT ON COLUMN public.consultations.analysis_type   IS 'face | palm';
COMMENT ON COLUMN public.consultations.analysis_id     IS 'readings.id 참조 — 원본 분석 결과';
COMMENT ON COLUMN public.consultations.context_summary IS '세션 시작 시점의 분석 요약 텍스트';
COMMENT ON COLUMN public.consultations.context_features IS '파생 지표 스냅샷 (readings.features 복사)';
COMMENT ON COLUMN public.consultations.model_used      IS 'E2B | E4B';

-- 상담 메시지 테이블
CREATE TABLE public.consultation_messages (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  consultation_id UUID        NOT NULL REFERENCES public.consultations(id) ON DELETE CASCADE,
  role            TEXT        NOT NULL CHECK (role IN ('user', 'assistant')),
  content         TEXT        NOT NULL,
  token_count     INT,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE  public.consultation_messages                 IS '상담 세션 내 개별 메시지';
COMMENT ON COLUMN public.consultation_messages.role           IS 'user | assistant';
COMMENT ON COLUMN public.consultation_messages.token_count    IS '추론 토큰 수 (모니터링용, nullable)';

-- 인덱스
CREATE INDEX consultations_user_id_idx
  ON public.consultations(user_id, last_message_at DESC);

CREATE INDEX consultations_analysis_idx
  ON public.consultations(analysis_type, analysis_id);

CREATE INDEX consultation_messages_consultation_id_idx
  ON public.consultation_messages(consultation_id, created_at ASC);

-- RLS — consultations
ALTER TABLE public.consultations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users can insert own consultations"
  ON public.consultations FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users can view own consultations"
  ON public.consultations FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users can update own consultations"
  ON public.consultations FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "users can delete own consultations"
  ON public.consultations FOR DELETE
  USING (auth.uid() = user_id);

-- RLS — consultation_messages
ALTER TABLE public.consultation_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users can insert messages to own consultations"
  ON public.consultation_messages FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.consultations c
      WHERE c.id = consultation_id
        AND c.user_id = auth.uid()
    )
  );

CREATE POLICY "users can view messages of own consultations"
  ON public.consultation_messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.consultations c
      WHERE c.id = consultation_id
        AND c.user_id = auth.uid()
    )
  );

CREATE POLICY "users can delete messages of own consultations"
  ON public.consultation_messages FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.consultations c
      WHERE c.id = consultation_id
        AND c.user_id = auth.uid()
    )
  );

-- 트리거: 메시지 추가 시 consultation 메타 자동 갱신
CREATE OR REPLACE FUNCTION public.update_consultation_meta()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.consultations
  SET message_count    = message_count + 1,
      last_message_at  = NEW.created_at
  WHERE id = NEW.consultation_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.update_consultation_meta IS
  'consultation_messages INSERT 후 consultations.message_count 및 last_message_at 자동 갱신';

CREATE TRIGGER consultation_message_inserted
  AFTER INSERT ON public.consultation_messages
  FOR EACH ROW EXECUTE FUNCTION public.update_consultation_meta();
