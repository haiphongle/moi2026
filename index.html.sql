-- ============================================================
-- THIET LAP KHO BAI VIET CHO WEB TIN TUC GIAI TRI (Supabase)
-- Cach dung: vao Supabase -> SQL Editor -> dan toan bo doan nay -> Run
-- Luu y: doi 'admin123' o dong danh dau (<<<) thanh mat khau quan tri cua ban
-- ============================================================

-- 1) Bang bai viet
create table if not exists public.articles (
  id bigint generated always as identity primary key,
  title text not null,
  category text not null default 'Sao Việt',
  summary text default '',
  content text not null,
  image_url text default '',
  created_at timestamptz not null default now()
);

alter table public.articles enable row level security;

-- Ai cung doc duoc bai viet (hien tren web cong khai)
drop policy if exists "Public read" on public.articles;
create policy "Public read" on public.articles
  for select using (true);

-- 2) Bang giu mat khau quan tri (khong ai doc duoc tu ngoai)
create table if not exists public.admin_config (
  id int primary key,
  admin_pass text not null
);

insert into public.admin_config (id, admin_pass)
values (1, 'admin123')   -- <<< DOI MAT KHAU O DAY truoc khi chay
on conflict (id) do update set admin_pass = excluded.admin_pass;

alter table public.admin_config enable row level security;
-- (co tinh khong tao policy nao => ben ngoai khong doc duoc bang nay)

-- 3) Ham dang bai (kiem tra mat khau ngay tai server)
create or replace function public.add_article(
  p_pass text, p_title text, p_category text,
  p_summary text, p_content text, p_image_url text
)
returns void
language plpgsql
security definer
as $$
begin
  if not exists (select 1 from public.admin_config where id = 1 and admin_pass = p_pass) then
    raise exception 'Sai mat khau quan tri';
  end if;
  insert into public.articles (title, category, summary, content, image_url)
  values (p_title, p_category, p_summary, p_content, p_image_url);
end;
$$;

-- 4) Ham xoa bai (kiem tra mat khau ngay tai server)
create or replace function public.delete_article(p_pass text, p_id bigint)
returns void
language plpgsql
security definer
as $$
begin
  if not exists (select 1 from public.admin_config where id = 1 and admin_pass = p_pass) then
    raise exception 'Sai mat khau quan tri';
  end if;
  delete from public.articles where id = p_id;
end;
$$;
