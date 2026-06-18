-- migrations/001_initial.sql

CREATE TABLE IF NOT EXISTS members (
  id            SERIAL PRIMARY KEY,
  mobile        VARCHAR(15) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role          VARCHAR(20) DEFAULT 'member',       -- president | secretary | member
  role_status   VARCHAR(20) DEFAULT 'approved',     -- approved | pending
  status        VARCHAR(10) DEFAULT 'active',       -- active | inactive
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS audit_logs (
  id          SERIAL PRIMARY KEY,
  actor_id    INTEGER REFERENCES members(id),
  action      TEXT NOT NULL,
  target_id   INTEGER,
  target_type VARCHAR(50),
  metadata    JSONB,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO members (mobile, password_hash, role, role_status, status)
VALUES (
  '9313774645',
  '{{ADMIN_PASSWORD_HASH}}',
  'admin',
  'approved',
  'active'
)
ON CONFLICT (mobile) DO NOTHING;
