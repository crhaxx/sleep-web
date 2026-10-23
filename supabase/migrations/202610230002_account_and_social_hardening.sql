create or replace function public.delete_own_account() returns void language plpgsql security definer set search_path=public,auth as $$
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  if coalesce((auth.jwt()->>'aal'),'aal1') <> 'aal2' and coalesce((auth.jwt()->>'iat')::bigint,0) < extract(epoch from now()-interval '5 minutes')::bigint then
    raise exception 'recent authentication required';
  end if;
  delete from auth.users where id=auth.uid();
end; $$;
revoke all on function public.delete_own_account() from public, anon;
-- Supabase's client API cannot delete auth.users directly. This narrowly-scoped
-- SECURITY DEFINER RPC deletes only the caller's own Auth row after client reauth.
grant execute on function public.delete_own_account() to authenticated;

create or replace function public.update_challenge_progress(cid uuid) returns integer language plpgsql security invoker set search_path=public as $$
declare c public.challenges%rowtype; calculated integer; participant_exists boolean;
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  select * into c from public.challenges where id=cid;
  if not found then raise exception 'challenge not found'; end if;
  select exists(select 1 from public.challenge_participants where challenge_id=cid and user_id=auth.uid()) into participant_exists;
  if not participant_exists then raise exception 'challenge participation required'; end if;
  if c.challenge_type='routine' then
    select least(c.target_value,count(*)::integer) into calculated from public.sleep_entries e where e.user_id=auth.uid() and e.sleep_date between c.start_date and c.end_date and e.estimated_sleep_minutes>=420;
  else
    select least(c.target_value,count(*)::integer) into calculated from public.sleep_entries e where e.user_id=auth.uid() and e.sleep_date between c.start_date and c.end_date;
  end if;
  update public.challenge_participants set progress=coalesce(calculated,0),completed_at=case when calculated>=c.target_value then now() else null end where challenge_id=cid and user_id=auth.uid();
  return coalesce(calculated,0);
end; $$;
revoke all on function public.update_challenge_progress(uuid) from public, anon;
grant execute on function public.update_challenge_progress(uuid) to authenticated;

drop policy if exists "participants visible" on public.challenge_participants;
create policy "participants visible" on public.challenge_participants for select to authenticated using(user_id=auth.uid() or exists(select 1 from public.challenges c where c.id=challenge_id and c.group_id is not null and public.is_group_member(c.group_id)) or (exists(select 1 from public.challenges c where c.id=challenge_id and c.visibility='friends' and public.are_friends(c.creator_id)) and exists(select 1 from public.profiles p where p.id=user_id and p.privacy_settings->>'challenge_progress' in ('friends','public'))));
create policy "self update challenge progress" on public.challenge_participants for update to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid());

create or replace function public.share_payload(raw_token text) returns jsonb language plpgsql stable security definer set search_path=public as $$
declare result jsonb;
begin
  if raw_token is null or length(raw_token)<30 or length(raw_token)>100 then return null; end if;
  select jsonb_build_object('title',p.title,'bedtime',p.bedtime,'wake_time',p.wake_time,'target_sleep_minutes',p.target_sleep_minutes,'estimated_latency_minutes',p.estimated_latency_minutes,'display_name',case when pr.privacy_settings->>'profile'='public' then pr.display_name else null end)
  into result from public.shared_plans s join public.sleep_plans p on p.id=s.plan_id join public.profiles pr on pr.id=s.owner_id
  where s.token_hash=encode(digest(raw_token,'sha256'),'hex') and s.visibility='link' and s.revoked_at is null and (s.expires_at is null or s.expires_at>now());
  return result;
end; $$;
revoke all on function public.share_payload(text) from public, anon, authenticated;
grant execute on function public.share_payload(text) to anon, authenticated;

create or replace function public.create_group_with_owner(group_name text, group_description text default null) returns uuid language plpgsql security invoker set search_path=public as $$
declare gid uuid;
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  if char_length(group_name) not between 2 and 80 or char_length(coalesce(group_description,''))>500 then raise exception 'invalid group details'; end if;
  insert into public.groups(owner_id,name,description) values(auth.uid(),group_name,group_description) returning id into gid;
  insert into public.group_members(group_id,user_id,role) values(gid,auth.uid(),'owner');
  return gid;
end; $$;
grant execute on function public.create_group_with_owner(text,text) to authenticated;
drop policy if exists "admins add member" on public.group_members;
create policy "admins add member" on public.group_members for insert to authenticated with check((user_id=auth.uid() and role='owner' and exists(select 1 from public.groups g where g.id=group_id and g.owner_id=auth.uid())) or (public.is_group_admin(group_id) and role='member'));

create or replace function public.prevent_group_role_escalation() returns trigger language plpgsql security definer set search_path=public as $$
begin
  if tg_op='INSERT' then
    if new.role='owner' and not exists(select 1 from public.groups g where g.id=new.group_id and g.owner_id=new.user_id and g.owner_id=auth.uid()) then raise exception 'owner role is reserved'; end if;
    if new.role='admin' and not public.is_group_admin(new.group_id) then raise exception 'group admin required'; end if;
  elsif tg_op='UPDATE' then
    if new.role='owner' and old.role<>'owner' then raise exception 'owner role cannot be self-assigned'; end if;
    if not public.is_group_admin(old.group_id) then raise exception 'group admin required'; end if;
  end if;
  return new;
end; $$;
create trigger group_role_guard before insert or update on public.group_members for each row execute function public.prevent_group_role_escalation();

create policy "search public discoverable profiles" on public.profiles for select to authenticated using (privacy_settings->>'discovery'='public' and privacy_settings->>'profile'='public' and not exists(select 1 from public.user_blocks b where b.blocker_id=id and b.blocked_user_id=auth.uid()) and not exists(select 1 from public.user_blocks b where b.blocker_id=auth.uid() and b.blocked_user_id=id));
create policy "shared plans self or explicit view" on public.shared_plans for select to authenticated using(owner_id=auth.uid() or (visibility='friends' and public.are_friends(owner_id) and revoked_at is null and (expires_at is null or expires_at>now())));

drop policy if exists "friendship involved update" on public.friendships;
create policy "addressee responds requester cancels" on public.friendships for update to authenticated using(requester_id=auth.uid() or addressee_id=auth.uid()) with check((requester_id=auth.uid() and status='pending') or (addressee_id=auth.uid() and status in ('accepted','rejected')));

create or replace function public.respond_group_invitation(invitation_id uuid, accept_invitation boolean) returns void language plpgsql security invoker set search_path=public as $$
declare gid uuid;
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  update public.group_invitations set status=case when accept_invitation then 'accepted'::public.invitation_status else 'rejected'::public.invitation_status end
  where id=invitation_id and invitee_id=auth.uid() and status='pending' and expires_at>now() returning group_id into gid;
  if gid is null then raise exception 'invitation unavailable'; end if;
  if accept_invitation then insert into public.group_members(group_id,user_id,role) values(gid,auth.uid(),'member') on conflict(group_id,user_id) do nothing; end if;
end; $$;
grant execute on function public.respond_group_invitation(uuid,boolean) to authenticated;

alter table public.sleep_plans force row level security;
alter table public.sleep_entries force row level security;
alter table public.friendships force row level security;
alter table public.user_blocks force row level security;
alter table public.groups force row level security;
alter table public.group_members force row level security;
alter table public.group_invitations force row level security;
alter table public.challenges force row level security;
alter table public.challenge_participants force row level security;
alter table public.shared_plans force row level security;
