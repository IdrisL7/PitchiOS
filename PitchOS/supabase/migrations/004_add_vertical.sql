-- 004_add_vertical.sql
-- Adds the sales vertical field to profiles.
-- Default: 'Enterprise SaaS' so existing rows are valid immediately.

alter table profiles
    add column if not exists vertical text not null default 'Enterprise SaaS';
