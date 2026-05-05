-- ============================================================
-- Mi Salud FdA — Schema Supabase v2
-- Ejecutar en: Supabase Dashboard > SQL Editor > New Query
-- ============================================================

-- Usuarios de la app
CREATE TABLE users (
  id            TEXT PRIMARY KEY,
  full_name     TEXT NOT NULL,
  email         TEXT,
  phone         TEXT,
  date_of_birth TEXT,
  gender        TEXT,
  blood_type    TEXT,
  weight        TEXT,
  height        TEXT,
  allergies     JSONB    DEFAULT '[]',
  avatar_url    TEXT     DEFAULT '',
  description   TEXT
);

-- Signos vitales por usuario
CREATE TABLE vital_signs (
  id       TEXT PRIMARY KEY,
  user_id  TEXT NOT NULL,
  label    TEXT,
  value    TEXT,
  date     TEXT,
  icon_key TEXT
);

-- Catálogo de médicos
CREATE TABLE doctors (
  id               TEXT PRIMARY KEY,
  name             TEXT,
  specialty        TEXT,
  avatar_url       TEXT    DEFAULT '',
  rating           FLOAT   DEFAULT 0,
  experience_years INT     DEFAULT 0,
  consultation_fee FLOAT   DEFAULT 0,
  available_slots  JSONB   DEFAULT '[]'
);

-- Sucursales (datos de CSV pendiente — seeded con datos de prueba)
CREATE TABLE branches (
  id        TEXT PRIMARY KEY,
  name      TEXT,
  address   TEXT,
  city      TEXT,
  state     TEXT,
  zip_code  TEXT,
  latitude  FLOAT,
  longitude FLOAT,
  phone     TEXT,
  schedule  TEXT,
  services  JSONB DEFAULT '[]'   -- ["vaccine","test","pharmacy","consultation"]
);

-- Catálogo de vacunas
CREATE TABLE vaccine_types (
  id          TEXT PRIMARY KEY,
  name        TEXT,
  description TEXT,
  doses       INT     DEFAULT 1,
  price       FLOAT   DEFAULT 0,
  age_range   TEXT
);

-- Catálogo de pruebas de laboratorio
CREATE TABLE test_types (
  id          TEXT PRIMARY KEY,
  name        TEXT,
  description TEXT,
  preparation TEXT,
  result_time TEXT,
  price       FLOAT DEFAULT 0
);

-- Citas médicas, vacunas y pruebas
CREATE TABLE appointments (
  id               TEXT PRIMARY KEY,
  user_id          TEXT NOT NULL,
  doctor_id        TEXT,
  doctor_name      TEXT,
  doctor_specialty TEXT,
  doctor_avatar    TEXT    DEFAULT '',
  branch_id        TEXT,
  branch_name      TEXT,
  vaccine_type_id  TEXT,
  test_type_id     TEXT,
  date             TEXT,
  time             TEXT,
  status           TEXT    DEFAULT 'upcoming',   -- upcoming | completed | cancelled
  type             TEXT    DEFAULT 'video',      -- video | in-person | vaccine | test
  payment_status   TEXT    DEFAULT 'pending',    -- pending | paid
  notes            TEXT    DEFAULT '',
  created_at       TEXT
);

-- Recetas digitales
CREATE TABLE prescriptions (
  id               TEXT PRIMARY KEY,
  user_id          TEXT NOT NULL,
  doctor_name      TEXT,
  doctor_specialty TEXT,
  date             TEXT,
  medications      JSONB DEFAULT '[]',  -- [{name, dosage, duration}]
  diagnosis        TEXT,
  notes            TEXT,
  qr_code_data     TEXT,
  status           TEXT DEFAULT 'active'  -- active | completed
);

-- Documentos clínicos
CREATE TABLE clinical_documents (
  id          TEXT PRIMARY KEY,
  user_id     TEXT NOT NULL,
  title       TEXT,
  type        TEXT,   -- lab_result | consultation_summary
  date        TEXT,
  doctor_name TEXT,
  summary     TEXT,
  status      TEXT DEFAULT 'available'
);

-- Documentos para firma
CREATE TABLE signature_documents (
  id              TEXT PRIMARY KEY,
  user_id         TEXT NOT NULL,
  title           TEXT,
  type            TEXT,   -- privacy_policy | consent_form | treatment_agreement
  date            TEXT,
  status          TEXT DEFAULT 'pending',  -- pending | signed
  content_preview TEXT
);

-- Promociones con imágenes reales
CREATE TABLE promotions (
  id          TEXT PRIMARY KEY,
  title       TEXT,
  description TEXT,
  image_url   TEXT    DEFAULT '',
  cta_text    TEXT,
  cta_action  TEXT,
  is_active   BOOLEAN DEFAULT TRUE
);

-- Actividad reciente por usuario
CREATE TABLE recent_activity (
  id       TEXT PRIMARY KEY,
  user_id  TEXT NOT NULL,
  title    TEXT,
  subtitle TEXT,
  date     TEXT,
  status   TEXT,  -- pending_payment | dispensed | completed
  type     TEXT   -- vaccine | test | prescription
);
