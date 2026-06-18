-- migrations/003_profile.sql

CREATE TABLE IF NOT EXISTS member_profiles (
  id                  SERIAL PRIMARY KEY,
  member_id           INTEGER UNIQUE REFERENCES members(id),
  -- Personal
  full_name           VARCHAR(100),
  email               VARCHAR(100),
  dob                 DATE,
  anniversary_date    DATE,
  native_place        VARCHAR(100),
  blood_group         VARCHAR(5),
  photo_url           TEXT,
  photo_drive_id      TEXT,
  -- Residential
  res_address         TEXT,
  res_phone           VARCHAR(15),
  -- Office
  office_address      TEXT,
  office_phone        VARCHAR(15),
  -- Mandal
  mandal_category     VARCHAR(50),
  mandal_position     VARCHAR(50),
  -- Spouse
  spouse_name         VARCHAR(100),
  spouse_mobile       VARCHAR(15),
  spouse_dob          DATE,
  spouse_photo_url    TEXT,
  spouse_photo_drive_id TEXT,
  profile_complete_pct INTEGER DEFAULT 0,
  created_at          TIMESTAMPTZ DEFAULT NOW(),
  updated_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS member_children (
  id              SERIAL PRIMARY KEY,
  member_id       INTEGER REFERENCES members(id),
  name            VARCHAR(100),
  dob             DATE,
  contact         VARCHAR(15),
  photo_url       TEXT,
  photo_drive_id  TEXT,
  sort_order      INTEGER DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_member_children_member ON member_children(member_id);
