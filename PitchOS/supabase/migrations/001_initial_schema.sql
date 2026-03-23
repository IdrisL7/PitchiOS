-- PitchOS Initial Schema
-- Run this against your Supabase project

-- Profiles: ICP configuration (extends auth.users)
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  role text not null,
  product text not null,
  industries text[] not null default '{}',
  buyer_titles text[] not null default '{}',
  methodology text not null default '',
  differentiators text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table profiles enable row level security;

create policy "Users can read own profile"
  on profiles for select
  using (auth.uid() = id);

create policy "Users can insert own profile"
  on profiles for insert
  with check (auth.uid() = id);

create policy "Users can update own profile"
  on profiles for update
  using (auth.uid() = id);

-- Deals / prospects
create table deals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  company_name text not null,
  contact_name text not null default '',
  contact_role text not null default '',
  stage text not null default 'discovery',
  outcome text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table deals enable row level security;

create policy "Users can manage own deals"
  on deals for all
  using (auth.uid() = user_id);

-- AI-generated outputs
create table outputs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  deal_id uuid references deals(id) on delete set null,
  type text not null,
  input jsonb not null default '{}',
  output text not null default '',
  prompt_version text not null,
  rating smallint,
  created_at timestamptz not null default now()
);

alter table outputs enable row level security;

create policy "Users can manage own outputs"
  on outputs for all
  using (auth.uid() = user_id);

-- Usage tracking (for tier enforcement)
create table usage (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  month text not null,
  generations int not null default 0,
  unique(user_id, month)
);

alter table usage enable row level security;

create policy "Users can read own usage"
  on usage for select
  using (auth.uid() = user_id);

-- Index for common queries
create index idx_deals_user_id on deals(user_id);
create index idx_outputs_user_id on outputs(user_id);
create index idx_outputs_deal_id on outputs(deal_id);
create index idx_usage_user_month on usage(user_id, month);
