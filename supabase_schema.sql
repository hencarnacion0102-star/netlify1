-- ============================================================
--  AccesoPRO — Supabase Schema
--  Ejecuta este script en: Supabase > SQL Editor > New Query
-- ============================================================

-- ─── EXTENSIONES ────────────────────────────────────────────
create extension if not exists "uuid-ossp";

-- ─── TABLA: admins ──────────────────────────────────────────
create table if not exists admins (
  id         uuid primary key default uuid_generate_v4(),
  username   text unique not null,
  password   text not null,          -- bcrypt hash
  full_name  text,
  created_at timestamptz default now()
);

-- Admin por defecto: usuario=admin / pass=admin123
-- (el hash se genera en el backend al iniciar)
insert into admins (username, password, full_name)
values ('admin', '$2b$10$placeholder', 'Administrador')
on conflict (username) do nothing;

-- ─── TABLA: departments ─────────────────────────────────────
create table if not exists departments (
  id    serial primary key,
  name  text unique not null,
  color text default '#64748b'
);

insert into departments (name, color) values
  ('Tecnología',       '#3b82f6'),
  ('Recursos Humanos', '#10b981'),
  ('Finanzas',         '#f59e0b'),
  ('Operaciones',      '#8b5cf6'),
  ('Ventas',           '#06b6d4'),
  ('Legal',            '#f97316'),
  ('Gerencia',         '#ec4899'),
  ('Marketing',        '#14b8a6'),
  ('Logística',        '#a78bfa')
on conflict (name) do nothing;

-- ─── TABLA: employees ───────────────────────────────────────
create table if not exists employees (
  id         uuid primary key default uuid_generate_v4(),
  first_name text not null,
  last_name  text not null,
  email      text unique,
  dept_id    integer references departments(id),
  role       text,
  pin        char(4) unique not null,
  status     text default 'out' check (status in ('in','out')),
  active     boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Empleados de ejemplo
insert into employees (first_name, last_name, email, dept_id, role, pin)
values
  ('Carlos', 'Méndez',   'c.mendez@empresa.com',   1, 'Desarrollador Senior',  '1234'),
  ('Ana',    'Torres',   'a.torres@empresa.com',   2, 'RRHH Manager',           '5678'),
  ('Luis',   'Ramírez',  'l.ramirez@empresa.com',  3, 'Analista Financiero',    '9012'),
  ('María',  'Santos',   'm.santos@empresa.com',   7, 'Directora General',      '3456'),
  ('Pedro',  'Castillo', 'p.castillo@empresa.com', 5, 'Ejecutivo de Cuenta',    '7890')
on conflict do nothing;

-- ─── TABLA: punch_logs ──────────────────────────────────────
create table if not exists punch_logs (
  id          uuid primary key default uuid_generate_v4(),
  employee_id uuid not null references employees(id) on delete cascade,
  type        text not null check (type in ('in','out')),
  punched_at  timestamptz default now(),
  ip_address  text,
  device      text
);

-- Índices para consultas frecuentes
create index if not exists idx_punch_logs_employee on punch_logs(employee_id);
create index if not exists idx_punch_logs_date     on punch_logs(punched_at desc);
create index if not exists idx_employees_pin       on employees(pin);

-- ─── FUNCIÓN: updated_at automático ─────────────────────────
create or replace function set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger employees_updated_at
  before update on employees
  for each row execute function set_updated_at();

-- ─── HABILITAR REALTIME ──────────────────────────────────────
-- En Supabase Dashboard > Database > Replication
-- activa las tablas: employees, punch_logs
alter publication supabase_realtime add table employees;
alter publication supabase_realtime add table punch_logs;

-- ─── ROW LEVEL SECURITY (RLS) ───────────────────────────────
-- Desactiva RLS para uso con service_role key (desde el backend)
alter table employees   disable row level security;
alter table punch_logs  disable row level security;
alter table departments disable row level security;
alter table admins      disable row level security;

-- ============================================================
-- ✅ Schema listo. Copia tu SUPABASE_URL y SUPABASE_SERVICE_KEY
--    al archivo .env del backend.
-- ============================================================
