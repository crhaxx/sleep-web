create extension if not exists pgcrypto;
create type public.friendship_status as enum ('pending','accepted','rejected');
create type public.invitation_status as enum ('pending','accepted','rejected','revoked');
create type public.group_role as enum ('owner','admin','member');
create type public.challenge_visibility as enum ('private','friends','group');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique check (username ~ '^[a-z0-9_]{3,24}$'),
  display_name text not null check (char_length(display_name) between 1 and 60),
  avatar_path text, bio text check (bio is null or char_length(bio)<=240), timezone text not null default 'UTC',
  preferred_language text not null default 'en' check (preferred_language in ('en','cs')),
  privacy_settings jsonb not null default '{"profile":"private","sleep_plans":"private","streaks":"private","challenge_progress":"private","discovery":"friends"}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.sleep_plans (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 80), bedtime time not null, wake_time time not null,
  target_sleep_minutes integer not null check (target_sleep_minutes between 180 and 720),
  estimated_latency_minutes integer not null default 15 check (estimated_latency_minutes between 0 and 120),
  weekly_schedule smallint[] not null default array[1,2,3,4,5,6,7]::smallint[] check (weekly_schedule <@ array[1,2,3,4,5,6,7]::smallint[]),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.sleep_entries (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  sleep_date date not null, actual_bedtime timestamptz not null, actual_wake_time timestamptz not null,
  estimated_sleep_minutes integer not null check (estimated_sleep_minutes between 0 and 1440),
  morning_energy_rating smallint check (morning_energy_rating between 1 and 5), subjective_sleep_quality smallint check (subjective_sleep_quality between 1 and 5),
  notes text check (notes is null or char_length(notes)<=2000), created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique(user_id,sleep_date), check (actual_wake_time > actual_bedtime)
);
create table public.friendships (
  id uuid primary key default gen_random_uuid(), requester_id uuid not null references auth.users(id) on delete cascade,
  addressee_id uuid not null references auth.users(id) on delete cascade, status public.friendship_status not null default 'pending',
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  check (requester_id <> addressee_id), unique(requester_id,addressee_id)
);
create unique index friendships_one_pair on public.friendships(least(requester_id,addressee_id),greatest(requester_id,addressee_id));
create table public.user_blocks (blocker_id uuid not null references auth.users(id) on delete cascade, blocked_user_id uuid not null references auth.users(id) on delete cascade, created_at timestamptz not null default now(), primary key(blocker_id,blocked_user_id), check(blocker_id<>blocked_user_id));
create table public.groups (id uuid primary key default gen_random_uuid(), owner_id uuid not null references auth.users(id) on delete cascade, name text not null check(char_length(name) between 2 and 80), description text check(description is null or char_length(description)<=500), avatar_path text, created_at timestamptz not null default now(), updated_at timestamptz not null default now());
create table public.group_members (group_id uuid not null references public.groups(id) on delete cascade, user_id uuid not null references auth.users(id) on delete cascade, role public.group_role not null default 'member', joined_at timestamptz not null default now(), primary key(group_id,user_id));
create table public.group_invitations (id uuid primary key default gen_random_uuid(), group_id uuid not null references public.groups(id) on delete cascade, inviter_id uuid not null references auth.users(id) on delete cascade, invitee_id uuid not null references auth.users(id) on delete cascade, status public.invitation_status not null default 'pending', expires_at timestamptz not null default (now()+interval '14 days'), created_at timestamptz not null default now(), check(inviter_id<>invitee_id), unique(group_id,invitee_id));
create table public.challenges (id uuid primary key default gen_random_uuid(), creator_id uuid not null references auth.users(id) on delete cascade, group_id uuid references public.groups(id) on delete cascade, title text not null check(char_length(title) between 3 and 100), description text check(description is null or char_length(description)<=1000), challenge_type text not null check(challenge_type in ('tracking','consistency','journal','routine')), target_value integer not null check(target_value between 1 and 90), start_date date not null, end_date date not null, visibility public.challenge_visibility not null default 'private', created_at timestamptz not null default now(), check(end_date>=start_date));
create table public.challenge_participants (challenge_id uuid not null references public.challenges(id) on delete cascade, user_id uuid not null references auth.users(id) on delete cascade, joined_at timestamptz not null default now(), progress integer not null default 0 check(progress>=0), completed_at timestamptz, primary key(challenge_id,user_id));
create table public.shared_plans (id uuid primary key default gen_random_uuid(), owner_id uuid not null references auth.users(id) on delete cascade, plan_id uuid not null references public.sleep_plans(id) on delete cascade, token_hash text unique, visibility text not null default 'private' check(visibility in ('private','friends','link')), expires_at timestamptz, revoked_at timestamptz, created_at timestamptz not null default now(), check((visibility='link' and token_hash is not null) or visibility<>'link'));

create index sleep_plans_owner on public.sleep_plans(user_id,created_at desc);
create index sleep_entries_owner_date on public.sleep_entries(user_id,sleep_date desc);
create index profiles_username on public.profiles(username);
create index friendships_addressee_status on public.friendships(addressee_id,status);
create index group_members_user on public.group_members(user_id,group_id);
create index challenges_dates on public.challenges(start_date,end_date);
create index challenge_participants_user on public.challenge_participants(user_id,challenge_id);

create function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
declare uname text; dname text;
begin
  uname := lower(coalesce(new.raw_user_meta_data->>'username', 'user_'||substr(new.id::text,1,8)));
  dname := coalesce(nullif(new.raw_user_meta_data->>'display_name',''), split_part(new.email,'@',1));
  insert into public.profiles(id,username,display_name) values(new.id,uname,dname);
  return new;
end; $$;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

create function public.is_group_member(gid uuid) returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from public.group_members gm where gm.group_id=gid and gm.user_id=auth.uid()); $$;
create function public.is_group_admin(gid uuid) returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from public.group_members gm where gm.group_id=gid and gm.user_id=auth.uid() and gm.role in ('owner','admin')); $$;
create function public.are_friends(other uuid) returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from public.friendships f where f.status='accepted' and ((f.requester_id=auth.uid() and f.addressee_id=other) or (f.requester_id=other and f.addressee_id=auth.uid()))); $$;

alter table public.profiles enable row level security;
alter table public.sleep_plans enable row level security;
alter table public.sleep_entries enable row level security;
alter table public.friendships enable row level security;
alter table public.user_blocks enable row level security;
alter table public.groups enable row level security;
alter table public.group_members enable row level security;
alter table public.group_invitations enable row level security;
alter table public.challenges enable row level security;
alter table public.challenge_participants enable row level security;
alter table public.shared_plans enable row level security;

create policy "profile self read" on public.profiles for select to authenticated using(id=auth.uid() or (privacy_settings->>'profile'='public' and not exists(select 1 from public.user_blocks b where b.blocker_id=id and b.blocked_user_id=auth.uid()) and not exists(select 1 from public.user_blocks b where b.blocker_id=auth.uid() and b.blocked_user_id=id)) or public.are_friends(id));
create policy "profile self update" on public.profiles for update to authenticated using(id=auth.uid()) with check(id=auth.uid());
create policy "profile search" on public.profiles for select to authenticated using(id=auth.uid());
create policy "plans owner all" on public.sleep_plans for all to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid());
create policy "entries owner all" on public.sleep_entries for all to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid());
create policy "friendship parties read" on public.friendships for select to authenticated using(requester_id=auth.uid() or addressee_id=auth.uid());
create policy "friendship requester create" on public.friendships for insert to authenticated with check(requester_id=auth.uid() and status='pending' and not exists(select 1 from public.user_blocks b where (b.blocker_id=auth.uid() and b.blocked_user_id=addressee_id) or (b.blocker_id=addressee_id and b.blocked_user_id=auth.uid())));
create policy "friendship involved update" on public.friendships for update to authenticated using(requester_id=auth.uid() or addressee_id=auth.uid()) with check((requester_id=auth.uid() or addressee_id=auth.uid()) and (status='accepted' or status='rejected' or (requester_id=auth.uid() and status='pending')));
create policy "friendship involved delete" on public.friendships for delete to authenticated using(requester_id=auth.uid() or addressee_id=auth.uid());
create policy "blocks self manage" on public.user_blocks for all to authenticated using(blocker_id=auth.uid()) with check(blocker_id=auth.uid());
create policy "group member read" on public.groups for select to authenticated using(owner_id=auth.uid() or public.is_group_member(id));
create policy "group owner create" on public.groups for insert to authenticated with check(owner_id=auth.uid());
create policy "group admin update" on public.groups for update to authenticated using(public.is_group_admin(id)) with check(public.is_group_admin(id));
create policy "group owner delete" on public.groups for delete to authenticated using(owner_id=auth.uid());
create policy "members read" on public.group_members for select to authenticated using(public.is_group_member(group_id));
create policy "admins add member" on public.group_members for insert to authenticated with check((user_id=auth.uid() and role='owner' and exists(select 1 from public.groups g where g.id=group_id and g.owner_id=auth.uid())) or (public.is_group_admin(group_id) and role in ('admin','member')));
create policy "admins change membership" on public.group_members for update to authenticated using(public.is_group_admin(group_id)) with check(public.is_group_admin(group_id) and role<>'owner');
create policy "member leave admin remove" on public.group_members for delete to authenticated using(user_id=auth.uid() or public.is_group_admin(group_id));
create policy "invitation parties" on public.group_invitations for select to authenticated using(inviter_id=auth.uid() or invitee_id=auth.uid() or public.is_group_admin(group_id));
create policy "admins invite" on public.group_invitations for insert to authenticated with check(inviter_id=auth.uid() and public.is_group_admin(group_id));
create policy "invitee respond" on public.group_invitations for update to authenticated using(invitee_id=auth.uid()) with check(invitee_id=auth.uid() and status in ('accepted','rejected'));
create policy "inviter cancel" on public.group_invitations for delete to authenticated using(inviter_id=auth.uid() or public.is_group_admin(group_id));
create policy "challenge visible read" on public.challenges for select to authenticated using(creator_id=auth.uid() or (visibility='friends' and public.are_friends(creator_id)) or (group_id is not null and public.is_group_member(group_id)) or exists(select 1 from public.challenge_participants p where p.challenge_id=id and p.user_id=auth.uid()));
create policy "challenge creator create" on public.challenges for insert to authenticated with check(creator_id=auth.uid() and (group_id is null or public.is_group_admin(group_id)));
create policy "challenge creator update" on public.challenges for update to authenticated using(creator_id=auth.uid()) with check(creator_id=auth.uid());
create policy "challenge creator delete" on public.challenges for delete to authenticated using(creator_id=auth.uid());
create policy "participants visible" on public.challenge_participants for select to authenticated using(user_id=auth.uid() or exists(select 1 from public.challenges c where c.id=challenge_id and c.group_id is not null and public.is_group_member(c.group_id)) or exists(select 1 from public.challenges c where c.id=challenge_id and c.visibility='friends' and public.are_friends(c.creator_id)));
create policy "join challenge" on public.challenge_participants for insert to authenticated with check(user_id=auth.uid() and progress=0 and completed_at is null);
create policy "self leave" on public.challenge_participants for delete to authenticated using(user_id=auth.uid());
create policy "shared plan owner manage" on public.shared_plans for all to authenticated using(owner_id=auth.uid()) with check(owner_id=auth.uid() and exists(select 1 from public.sleep_plans p where p.id=plan_id and p.user_id=auth.uid()));

grant select,insert,update,delete on public.profiles, public.sleep_plans, public.sleep_entries, public.friendships, public.user_blocks, public.groups, public.group_members, public.group_invitations, public.challenges, public.challenge_participants, public.shared_plans to authenticated;
grant execute on function public.is_group_member(uuid),public.is_group_admin(uuid),public.are_friends(uuid) to authenticated;
