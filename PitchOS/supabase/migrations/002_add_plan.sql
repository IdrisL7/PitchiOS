-- PitchOS: Add subscription plan to profiles
-- Adds a `plan` column (free | pro) with a default of 'free'.
-- To upgrade a user in development: UPDATE profiles SET plan = 'pro' WHERE id = '<user-uuid>';

alter table profiles
  add column if not exists plan text not null default 'free'
  check (plan in ('free', 'pro'));

-- Convenience: upgrade the local test user to pro automatically
-- (remove or gate on env if you don't want this in production migrations)
update profiles
  set plan = 'pro'
  where id in (
    select id from auth.users where email = 'test@pitchos.dev'
  );
