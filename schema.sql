-- ============================================================
-- ESTIMATE（株式会社Plus 見積・請求アプリ）Supabase 初期設定
-- Supabase の SQL Editor に貼り付けて実行してください（1回だけ）
-- ============================================================

-- 1) アプリのデータ置き場
--    key = 'plus_estimate_shared_v2'  … 会社全体で共有するデータ（見積・請求書・顧客・マスター・設定）
--    key = 'u:<ユーザーID>:...'         … その人だけの下書き
create table if not exists public.app_state (
  key        text primary key,
  value      text not null,
  updated_at timestamptz not null default now()
);

-- 2) 行ごとの安全設定（ログインした人だけ読み書きできる。下書きは本人のみ）
alter table public.app_state enable row level security;

drop policy if exists "app_state_select" on public.app_state;
create policy "app_state_select" on public.app_state
  for select to authenticated
  using (key not like 'u:%' or key like 'u:' || auth.uid()::text || ':%');

drop policy if exists "app_state_insert" on public.app_state;
create policy "app_state_insert" on public.app_state
  for insert to authenticated
  with check (key not like 'u:%' or key like 'u:' || auth.uid()::text || ':%');

drop policy if exists "app_state_update" on public.app_state;
create policy "app_state_update" on public.app_state
  for update to authenticated
  using (key not like 'u:%' or key like 'u:' || auth.uid()::text || ':%')
  with check (key not like 'u:%' or key like 'u:' || auth.uid()::text || ':%');

drop policy if exists "app_state_delete" on public.app_state;
create policy "app_state_delete" on public.app_state
  for delete to authenticated
  using (key like 'u:' || auth.uid()::text || ':%');

-- 3) 他の端末の変更をすぐ反映する（リアルタイム）
do $$
begin
  if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and tablename = 'app_state') then
    alter publication supabase_realtime add table public.app_state;
  end if;
end $$;
