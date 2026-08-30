-- ============================================================
-- Supabase SQL: 创建快速切换模型标签的高性能聚合函数 (get_model_tags)
-- 在 Supabase Dashboard -> SQL Editor 中粘贴并点击 "Run" 执行
-- ============================================================

create or replace function public.get_model_tags(min_count int default 8)
returns table (name text, count bigint)
language sql
stable
security definer
as $$
  select 
    btrim(model_name) as name, 
    count(*)::bigint as count
  from public.speed_results
  where model_name is not null 
    and btrim(model_name) != ''
  group by btrim(model_name)
  having count(*) >= min_count
  order by count desc, name asc;
$$;

-- 授予 anon (公开访问) 与 authenticated 角色执行权限
grant execute on function public.get_model_tags(int) to anon, authenticated, service_role;

comment on function public.get_model_tags(int) is
  'Aggregates model names from speed_results with count >= min_count for fast leaderboard tagging.';
