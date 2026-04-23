-- readings 테이블에 subject_name 컬럼 추가
-- 미입력 시 '나' 기본값, null 허용 (기존 레코드 호환)
alter table readings
  add column if not exists subject_name text not null default '나';
