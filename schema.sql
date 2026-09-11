-- ============================================================
-- Bolt & Bahi — Supabase schema
-- Paste this whole file into Supabase SQL Editor and run it once.
-- ============================================================

-- ---------- extensions ----------
create extension if not exists "pgcrypto";

-- ============================================================
-- ORG, ROLES, PROFILES
-- ============================================================

create table organizations (
  id uuid primary key default gen_random_uuid(),
  business_name text not null default '',
  gstin text default '',
  state text default '',
  invoice_prefix text default 'BB',
  next_retail_no integer not null default 1,
  next_wholesale_no integer not null default 1,
  created_at timestamptz not null default now()
);

create table role_definitions (
  id text not null,
  org_id uuid not null references organizations(id) on delete cascade,
  name text not null,
  rank integer not null default 0,
  allowed_tabs text[] not null default '{}',
  hide_margins boolean not null default true,
  hide_outstanding boolean not null default true,
  created_at timestamptz not null default now(),
  primary key (org_id, id)
);

create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  org_id uuid not null references organizations(id) on delete cascade,
  role_id text not null,
  display_name text default '',
  phone text default '',
  created_at timestamptz not null default now(),
  foreign key (org_id, role_id) references role_definitions(org_id, id)
);

-- helper functions used by every RLS policy below
create or replace function auth_org_id() returns uuid
language sql stable security definer set search_path = public as $$
  select org_id from profiles where id = auth.uid();
$$;

create or replace function auth_role_id() returns text
language sql stable security definer set search_path = public as $$
  select role_id from profiles where id = auth.uid();
$$;

create or replace function auth_can_access(tab text) returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce(
    (select tab = any(rd.allowed_tabs)
     from profiles p join role_definitions rd on rd.org_id = p.org_id and rd.id = p.role_id
     where p.id = auth.uid()),
    false
  );
$$;

create or replace function auth_hide_margins() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce(
    (select rd.hide_margins from profiles p join role_definitions rd on rd.org_id = p.org_id and rd.id = p.role_id where p.id = auth.uid()),
    true
  );
$$;

create or replace function auth_hide_outstanding() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce(
    (select rd.hide_outstanding from profiles p join role_definitions rd on rd.org_id = p.org_id and rd.id = p.role_id where p.id = auth.uid()),
    true
  );
$$;

-- ============================================================
-- INVENTORY
-- ============================================================

create table fabrics (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  name text not null,
  type text default '',
  design text default '',
  color text default '',
  count text default '',
  construction text default '',
  blend text default '',
  gsm numeric default 0,
  width numeric default 0,
  unit text not null default 'm',
  cost numeric not null default 0,
  retail_price numeric not null default 0,
  moq numeric not null default 1,
  reorder_level numeric not null default 0,
  hsn_code text default '',
  gst_rate numeric not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table fabric_rolls (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  fabric_id uuid not null references fabrics(id) on delete cascade,
  lot text default '',
  qty numeric not null default 0,
  location text default 'Main Godown'
);

create table wholesale_price_slabs (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  fabric_id uuid not null references fabrics(id) on delete cascade,
  min_qty numeric not null default 1,
  price numeric not null default 0
);

-- ============================================================
-- PARTIES
-- ============================================================

create table retail_customers (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  name text not null,
  phone text default '',
  created_at timestamptz not null default now()
);

create table wholesale_customers (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  business_name text not null,
  phone text default '',
  city text default '',
  state text default '',
  gstin text default '',
  credit_limit numeric not null default 0,
  outstanding numeric not null default 0,
  created_at timestamptz not null default now()
);

create table suppliers (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  name text not null,
  phone text default '',
  city text default '',
  state text default '',
  gstin text default '',
  amount_owed numeric not null default 0,
  created_at timestamptz not null default now()
);

create table agents (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  name text not null,
  phone text default '',
  commission_rate numeric not null default 0,
  created_at timestamptz not null default now()
);

-- ============================================================
-- RETAIL ORDERS
-- ============================================================

create table retail_orders (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  invoice_no text not null,
  date date not null default current_date,
  customer_id uuid references retail_customers(id) on delete set null,
  taxable numeric not null default 0,
  cgst numeric not null default 0,
  sgst numeric not null default 0,
  total numeric not null default 0,
  payment_mode text default 'cash',
  created_at timestamptz not null default now()
);

create table retail_order_items (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  order_id uuid not null references retail_orders(id) on delete cascade,
  fabric_id uuid references fabrics(id) on delete set null,
  name text not null,
  unit text not null default 'm',
  meters numeric not null default 0,
  rate numeric not null default 0,
  amount numeric not null default 0,
  gst_rate numeric not null default 0
);

-- ============================================================
-- WHOLESALE ORDERS
-- ============================================================

create table wholesale_orders (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  invoice_no text not null,
  date date not null default current_date,
  customer_id uuid references wholesale_customers(id) on delete set null,
  taxable numeric not null default 0,
  cgst numeric not null default 0,
  sgst numeric not null default 0,
  igst numeric not null default 0,
  total numeric not null default 0,
  credit_term text default 'advance',
  status text not null default 'draft',
  agent_id uuid references agents(id) on delete set null,
  commission_amount numeric not null default 0,
  commission_paid boolean not null default false,
  created_at timestamptz not null default now()
);

create table wholesale_order_items (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  order_id uuid not null references wholesale_orders(id) on delete cascade,
  fabric_id uuid references fabrics(id) on delete set null,
  name text not null,
  unit text not null default 'm',
  qty numeric not null default 0,
  rate numeric not null default 0,
  amount numeric not null default 0,
  gst_rate numeric not null default 0,
  dispatched_qty numeric not null default 0,
  returned_qty numeric not null default 0
);

create table credit_notes (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  wholesale_order_id uuid references wholesale_orders(id) on delete cascade,
  fabric_id uuid references fabrics(id) on delete set null,
  type text not null default 'return',
  qty numeric not null default 0,
  amount numeric not null default 0,
  note text default '',
  date date not null default current_date
);

-- ============================================================
-- LOGISTICS
-- ============================================================

create table dispatches (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  wholesale_order_id uuid references wholesale_orders(id) on delete set null,
  transporter text default '',
  lr text default '',
  vehicle text default '',
  freight numeric default 0,
  dispatch_date date not null default current_date,
  expected_delivery date,
  destination text default '',
  status text not null default 'transit',
  eway_bill text default '',
  packages integer default 0,
  weight numeric default 0
);

create table dispatch_items (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  dispatch_id uuid not null references dispatches(id) on delete cascade,
  fabric_id uuid references fabrics(id) on delete set null,
  name text not null,
  qty numeric not null default 0
);

-- ============================================================
-- JOB WORK
-- ============================================================

create table job_work (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  fabric_id uuid references fabrics(id) on delete set null,
  fabric_name text not null,
  unit text not null default 'm',
  process_type text not null default 'dyeing',
  processor text default '',
  qty_sent numeric not null default 0,
  qty_returned numeric,
  sent_date date not null default current_date,
  expected_return_date date,
  status text not null default 'sent'
);

-- ============================================================
-- MONEY
-- ============================================================

create table payments (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  customer_id uuid references wholesale_customers(id) on delete cascade,
  amount numeric not null default 0,
  date date not null default current_date,
  type text not null default 'payment',
  note text default ''
);

create table cheques (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  customer_id uuid references wholesale_customers(id) on delete cascade,
  cheque_no text not null,
  bank text default '',
  amount numeric not null default 0,
  due_date date not null default current_date,
  status text not null default 'pending'
);

create table supplier_transactions (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  supplier_id uuid not null references suppliers(id) on delete cascade,
  date date not null default current_date,
  type text not null default 'purchase',
  amount numeric not null default 0,
  note text default ''
);

-- ============================================================
-- RLS — enable on every table
-- ============================================================

alter table organizations enable row level security;
alter table role_definitions enable row level security;
alter table profiles enable row level security;
alter table fabrics enable row level security;
alter table fabric_rolls enable row level security;
alter table wholesale_price_slabs enable row level security;
alter table retail_customers enable row level security;
alter table wholesale_customers enable row level security;
alter table suppliers enable row level security;
alter table agents enable row level security;
alter table retail_orders enable row level security;
alter table retail_order_items enable row level security;
alter table wholesale_orders enable row level security;
alter table wholesale_order_items enable row level security;
alter table credit_notes enable row level security;
alter table dispatches enable row level security;
alter table dispatch_items enable row level security;
alter table job_work enable row level security;
alter table payments enable row level security;
alter table cheques enable row level security;
alter table supplier_transactions enable row level security;

-- org + profile: a user can only see their own org and profile
create policy org_read on organizations for select using (id = auth_org_id());
create policy org_write on organizations for update using (id = auth_org_id() and auth_role_id() = 'owner');
create policy roles_read on role_definitions for select using (org_id = auth_org_id());
create policy roles_write on role_definitions for all using (org_id = auth_org_id() and auth_role_id() = 'owner');
create policy profile_read on profiles for select using (org_id = auth_org_id());
create policy profile_write_self on profiles for update using (id = auth.uid());

-- inventory: gated on the 'inventory' tab
create policy fabrics_rw on fabrics for all
  using (org_id = auth_org_id() and auth_can_access('inventory'))
  with check (org_id = auth_org_id() and auth_can_access('inventory'));
create policy rolls_rw on fabric_rolls for all
  using (org_id = auth_org_id() and auth_can_access('inventory'))
  with check (org_id = auth_org_id() and auth_can_access('inventory'));
create policy slabs_rw on wholesale_price_slabs for all
  using (org_id = auth_org_id() and auth_can_access('inventory'))
  with check (org_id = auth_org_id() and auth_can_access('inventory'));

-- retail
create policy retail_orders_rw on retail_orders for all
  using (org_id = auth_org_id() and auth_can_access('retail'))
  with check (org_id = auth_org_id() and auth_can_access('retail'));
create policy retail_items_rw on retail_order_items for all
  using (org_id = auth_org_id() and auth_can_access('retail'))
  with check (org_id = auth_org_id() and auth_can_access('retail'));

-- wholesale
create policy wholesale_orders_rw on wholesale_orders for all
  using (org_id = auth_org_id() and auth_can_access('wholesale'))
  with check (org_id = auth_org_id() and auth_can_access('wholesale'));
create policy wholesale_items_rw on wholesale_order_items for all
  using (org_id = auth_org_id() and auth_can_access('wholesale'))
  with check (org_id = auth_org_id() and auth_can_access('wholesale'));
create policy credit_notes_rw on credit_notes for all
  using (org_id = auth_org_id() and auth_can_access('wholesale'))
  with check (org_id = auth_org_id() and auth_can_access('wholesale'));

-- logistics
create policy dispatches_rw on dispatches for all
  using (org_id = auth_org_id() and auth_can_access('logistics'))
  with check (org_id = auth_org_id() and auth_can_access('logistics'));
create policy dispatch_items_rw on dispatch_items for all
  using (org_id = auth_org_id() and auth_can_access('logistics'))
  with check (org_id = auth_org_id() and auth_can_access('logistics'));

-- job work
create policy jobwork_rw on job_work for all
  using (org_id = auth_org_id() and auth_can_access('jobwork'))
  with check (org_id = auth_org_id() and auth_can_access('jobwork'));

-- customers tab: retail/wholesale customers, suppliers, agents, cheques, payments, supplier_transactions
create policy retail_cust_rw on retail_customers for all
  using (org_id = auth_org_id() and auth_can_access('customers'))
  with check (org_id = auth_org_id() and auth_can_access('customers'));
create policy wholesale_cust_rw on wholesale_customers for all
  using (org_id = auth_org_id() and auth_can_access('customers'))
  with check (org_id = auth_org_id() and auth_can_access('customers'));
create policy suppliers_rw on suppliers for all
  using (org_id = auth_org_id() and auth_can_access('customers'))
  with check (org_id = auth_org_id() and auth_can_access('customers'));
create policy agents_rw on agents for all
  using (org_id = auth_org_id() and auth_can_access('customers'))
  with check (org_id = auth_org_id() and auth_can_access('customers'));
create policy cheques_rw on cheques for all
  using (org_id = auth_org_id() and auth_can_access('customers'))
  with check (org_id = auth_org_id() and auth_can_access('customers'));
create policy payments_rw on payments for all
  using (org_id = auth_org_id() and auth_can_access('customers'))
  with check (org_id = auth_org_id() and auth_can_access('customers'));
create policy supplier_txns_rw on supplier_transactions for all
  using (org_id = auth_org_id() and auth_can_access('customers'))
  with check (org_id = auth_org_id() and auth_can_access('customers'));

-- ============================================================
-- MASKED VIEWS — the actual column-level enforcement
-- RLS protects rows/tables; these views protect specific fields
-- (fabric cost, customer/supplier/agent money figures) so a
-- hide_margins / hide_outstanding role never receives them from
-- the database at all, not just has them hidden by the frontend.
-- ============================================================

create view fabrics_view as
  select
    id, org_id, name, type, design, color, count, construction, blend,
    gsm, width, unit, moq, reorder_level, hsn_code, gst_rate, retail_price,
    case when auth_hide_margins() then null else cost end as cost
  from fabrics
  where org_id = auth_org_id();

create view wholesale_customers_view as
  select
    id, org_id, business_name, phone, city, state, gstin, credit_limit,
    case when auth_hide_outstanding() then null else outstanding end as outstanding
  from wholesale_customers
  where org_id = auth_org_id();

create view suppliers_view as
  select
    id, org_id, name, phone, city, state, gstin,
    case when auth_hide_outstanding() then null else amount_owed end as amount_owed
  from suppliers
  where org_id = auth_org_id();

create view agents_view as
  select
    id, org_id, name, phone,
    case when auth_hide_outstanding() then null else commission_rate end as commission_rate
  from agents
  where org_id = auth_org_id();

create view cheques_view as
  select
    id, org_id, customer_id, cheque_no, bank, due_date, status,
    case when auth_hide_outstanding() then null else amount end as amount
  from cheques
  where org_id = auth_org_id();

-- ============================================================
-- SEED: the 10 existing roles, per organization at signup time.
-- Call this once right after creating a new organization row.
-- ============================================================

create or replace function seed_default_roles(target_org uuid) returns void
language sql as $$
  insert into role_definitions (org_id, id, name, rank, allowed_tabs, hide_margins, hide_outstanding) values
    (target_org, 'owner',           'Default User',        100, array['dashboard','inventory','retail','wholesale','jobwork','logistics','customers','settings'], false, false),
    (target_org, 'gm',              'General Manager',      90, array['dashboard','inventory','retail','wholesale','jobwork','logistics','customers'],            false, false),
    (target_org, 'sales_manager',   'Sales Manager',         70, array['dashboard','retail','wholesale','customers','inventory'],                                   false, false),
    (target_org, 'warehouse_manager','Warehouse Manager',    70, array['dashboard','inventory','jobwork','logistics'],                                              false, true),
    (target_org, 'accountant',      'Accountant / Munim',    60, array['dashboard','customers','settings'],                                                         true,  false),
    (target_org, 'retail_supervisor','Retail Supervisor',    50, array['dashboard','retail'],                                                                       false, true),
    (target_org, 'wholesale_rep',   'Wholesale Sales Rep',   30, array['dashboard','wholesale','inventory'],                                                        true,  true),
    (target_org, 'counter',         'Counter Staff',         20, array['retail'],                                                                                   true,  true),
    (target_org, 'godown',          'Godown Keeper',         20, array['inventory','jobwork','logistics'],                                                          true,  true),
    (target_org, 'dispatch',        'Dispatch Coordinator',  15, array['logistics'],                                                                                true,  true);
$$;
