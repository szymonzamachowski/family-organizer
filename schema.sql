-- Run this script in the Supabase SQL Editor

-- 1. Create Tables

create table if not exists public.tasks (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  assigned_to text,
  deadline date,
  status text default 'todo', -- 'todo', 'done'
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table if not exists public.shopping_list (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  is_bought boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table if not exists public.wishlist (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  status text default 'active', -- 'active', 'bought'
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table if not exists public.meal_plan (
  id uuid default gen_random_uuid() primary key,
  day_date date not null,
  dish_name text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table if not exists public.weekend_tasks (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  is_completed boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Enable Row Level Security (RLS) and allow public access (Since no auth needed)

alter table public.tasks enable row level security;
create policy "Enable all access for tasks" on public.tasks for all using (true) with check (true);

alter table public.shopping_list enable row level security;
create policy "Enable all access for shopping_list" on public.shopping_list for all using (true) with check (true);

alter table public.wishlist enable row level security;
create policy "Enable all access for wishlist" on public.wishlist for all using (true) with check (true);

alter table public.meal_plan enable row level security;
create policy "Enable all access for meal_plan" on public.meal_plan for all using (true) with check (true);

alter table public.weekend_tasks enable row level security;
create policy "Enable all access for weekend_tasks" on public.weekend_tasks for all using (true) with check (true);

-- 3. Enable Realtime

-- Note: Sometimes 'supabase_realtime' publication exists by default.
-- We try to create it if not exists, or just add tables to it.

do $$
begin
  if not exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    create publication supabase_realtime;
  end if;
end
$$;

alter publication supabase_realtime add table public.tasks, public.shopping_list, public.wishlist, public.meal_plan, public.weekend_tasks;
