-- PitchOS: Add Solo plan support for App Store subscriptions.

alter table profiles drop constraint if exists profiles_plan_check;
alter table profiles
  add constraint profiles_plan_check
  check (plan in ('free', 'solo', 'pro', 'team'));
