-- ============================================================
-- 参考：Ver.2 以降で移行する予定の本格的なテーブル設計（仕様書 §29〜31）
-- いまのアプリは app_state（schema.sql）だけで動きます。このファイルはまだ実行しません。
-- ============================================================
create table companies (
  id uuid primary key default gen_random_uuid(),
  name text not null, rep text, zip text, address text, tel text, fax text, email text,
  invoice_no text, license text, bank text, logo_url text, stamp_url text,
  valid_days int default 30, tax_rate int default 10, gp_warn int default 25, due_days int default 30,
  notes text, notes_footer text, invoice_lead text, invoice_notes text, created_at timestamptz default now()
);
create table users (
  id uuid primary key references auth.users(id), company_id uuid references companies(id),
  name text not null, email text not null, role text not null check (role in ('管理者','作成者')),
  active boolean default true, created_at timestamptz default now()
);
create table customers (
  id uuid primary key default gen_random_uuid(), company_id uuid references companies(id),
  type text check (type in ('個人','法人')), name text, company text, contact text, title text,
  zip text, address text, tel text, mobile text, email text, memo text, created_at timestamptz default now()
);
create table work_items (
  id uuid primary key default gen_random_uuid(), company_id uuid references companies(id),
  cat text, name text not null, unit text, price numeric default 0, cost numeric default 0, sort_order int
);
create table products (
  id uuid primary key default gen_random_uuid(), company_id uuid references companies(id),
  maker text, name text not null, model text, cat text, list_price numeric, cost numeric, price numeric, tax_type text, memo text
);
create table estimate_templates (
  id uuid primary key default gen_random_uuid(), company_id uuid references companies(id), name text not null, description text, needs_product boolean default false
);
create table estimate_template_items (
  id uuid primary key default gen_random_uuid(), template_id uuid references estimate_templates(id) on delete cascade,
  work_item_id uuid references work_items(id), product_id uuid references products(id), quantity numeric default 1, sort_order int
);
create table estimates (
  id uuid primary key default gen_random_uuid(), company_id uuid references companies(id),
  estimate_number text not null, customer_id uuid references customers(id), project_name text,
  site_name text, site_address text, work_date date, property_name text,
  issue_date date, expiry_date date, delivery text, place text, payment text,
  subtotal numeric, discount numeric default 0, tax numeric, total numeric, cost_total numeric, gross_profit numeric, gross_profit_rate numeric,
  status text default '作成中', notes text, site_memo text,
  staff_id uuid references users(id), created_by uuid references users(id),
  created_at timestamptz default now(), updated_at timestamptz default now()
);
create table estimate_items (
  id uuid primary key default gen_random_uuid(), estimate_id uuid references estimates(id) on delete cascade,
  product_id uuid references products(id), work_item_id uuid references work_items(id),
  name text not null, description text, quantity numeric, unit text, unit_price numeric, cost_price numeric, amount numeric, sort_order int
);
create table invoices (
  id uuid primary key default gen_random_uuid(), company_id uuid references companies(id),
  invoice_number text not null, estimate_id uuid references estimates(id), customer_id uuid references customers(id),
  project_name text, property_name text, issue_date date, due_date date, paid_date date,
  discount numeric default 0, status text default '未送付', notes text,
  staff_id uuid references users(id), created_at timestamptz default now(), updated_at timestamptz default now()
);
create table invoice_items (
  id uuid primary key default gen_random_uuid(), invoice_id uuid references invoices(id) on delete cascade,
  date_label text, name text not null, description text, quantity numeric, unit text, unit_price numeric, cost_price numeric, expense numeric default 0, sort_order int
);
create table attachments (
  id uuid primary key default gen_random_uuid(), estimate_id uuid references estimates(id) on delete cascade,
  kind text, url text not null, memo text, created_at timestamptz default now()
);
