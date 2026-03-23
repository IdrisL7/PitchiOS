-- PitchOS: Add Team plan support
-- Extends the plan check constraint and adds team metadata columns.

-- 1. Drop & re-add check constraint to include 'team'
alter table profiles drop constraint if exists profiles_plan_check;
alter table profiles
  add constraint profiles_plan_check
  check (plan in ('free', 'pro', 'team'));

-- 2. Team metadata columns (nullable — only populated for team members)
alter table profiles
  add column if not exists team_name       text,
  add column if not exists team_seat_count int,
  add column if not exists team_seat_used  int,
  add column if not exists team_is_admin   boolean not null default false;

-- 3. Upgrade test user to team plan with sample data
update profiles
  set plan           = 'team',
      team_name      = 'Acme Corp — Enterprise Sales',
      team_seat_count = 10,
      team_seat_used  = 7,
      team_is_admin   = true
  where id in (
    select id from auth.users where email = 'test@pitchos.dev'
  );
