-- =============================================================================
-- Migration: 20260423000002_fix_analysis_id_fk.sql
-- Fix: consultations.analysis_id was NOT NULL + ON DELETE SET NULL (contradiction)
-- PostgreSQL cannot SET NULL a NOT NULL column → DELETE from readings fails.
-- Resolution: change FK to ON DELETE CASCADE so that deleting a reading also
-- removes associated consultations (and their messages via the existing cascade).
-- =============================================================================

ALTER TABLE public.consultations
  DROP CONSTRAINT IF EXISTS consultations_analysis_id_fkey;

ALTER TABLE public.consultations
  ADD CONSTRAINT consultations_analysis_id_fkey
  FOREIGN KEY (analysis_id)
  REFERENCES public.readings(id)
  ON DELETE CASCADE;
