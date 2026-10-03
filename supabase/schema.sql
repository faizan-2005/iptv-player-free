create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz default now()
);

create table if not exists favorites (
  id bigint generated always as identity primary key,
  user_id uuid references profiles(id) on delete cascade,
  stream_id text not null,
  kind text not null default 'live',
  name text,
  logo text,
  created_at timestamptz default now(),
  unique(user_id, stream_id)
);

create table if not exists entitlements (
  user_id uuid primary key references profiles(id) on delete cascade,
  tier text not null default 'free',
  updated_at timestamptz default now()
);

alter table profiles enable row level security;
alter table favorites enable row level security;
alter table entitlements enable row level security;

drop policy if exists "own profile" on profiles;
create policy "own profile" on profiles for all using (auth.uid() = id);

drop policy if exists "own favorites" on favorites;
create policy "own favorites" on favorites for all using (auth.uid() = user_id);

drop policy if exists "own entitlement" on entitlements;
create policy "own entitlement" on entitlements for select using (auth.uid() = user_id);
