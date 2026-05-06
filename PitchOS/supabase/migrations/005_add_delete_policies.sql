-- Allow authenticated users to delete their own deals and generated outputs.
-- Production was missing DELETE policies even though the app-side delete call exists.

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'deals'
      and policyname = 'Users can delete own deals'
  ) then
    create policy "Users can delete own deals"
      on public.deals
      for delete
      using (auth.uid() = user_id);
  end if;
end $$;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'outputs'
      and policyname = 'Users can delete own outputs'
  ) then
    create policy "Users can delete own outputs"
      on public.outputs
      for delete
      using (auth.uid() = user_id);
  end if;
end $$;
