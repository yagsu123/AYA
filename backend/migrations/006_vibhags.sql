-- migrations/006_vibhags.sql
-- Phase 6 — Events & the six Vibhag modules.
--   * vibhags            : the six community divisions (seeded, first-class rows)
--   * vibhag_heads       : members appointed to manage a vibhag's events
--   * event_sponsorships : labarthi / sponsor sign-ups against an event
-- The events table itself was created early in 004; here it gains a foreign key
-- to vibhags plus an updated_by column, without dropping any existing data.

CREATE TABLE IF NOT EXISTS vibhags (
  type         VARCHAR(30) PRIMARY KEY,  -- stable machine key (sangeet, seva, ...)
  name         VARCHAR(60)  NOT NULL,
  description  TEXT,
  color        VARCHAR(9)   NOT NULL DEFAULT '#2992D6',  -- hex, drives UI accent
  icon         VARCHAR(40)  NOT NULL DEFAULT 'event',     -- icon key, mapped in app
  sort_order   INTEGER      NOT NULL DEFAULT 0,
  created_at   TIMESTAMPTZ  DEFAULT NOW(),
  updated_at   TIMESTAMPTZ  DEFAULT NOW()
);

-- Seed the six vibhags. Names/descriptions are editable later by admins; the
-- type keys are fixed because events and heads reference them.
INSERT INTO vibhags (type, name, description, color, icon, sort_order) VALUES
  ('paryushan', 'Paryushan',  'The great festival of forgiveness, fasting and reflection — the spiritual high point of the Jain year.', '#E8940A', 'local_fire_department', 1),
  ('snatra',    'Snatra Puja', 'Daily and occasion abhishek of the Jina, performed with devotion and ritual purity.',                 '#2992D6', 'spa',                  2),
  ('sangeet',   'Sangeet',    'Devotional music and bhakti — bhavnas, stavans and community singing.',                                '#7C3AED', 'music_note',           3),
  ('aangi',     'Aangi',      'Adornment and decoration of the idol for festivals and special occasions.',                           '#EF4444', 'checkroom',            4),
  ('seva',      'Seva',       'Selfless community service — supporting members, events and those in need.',                          '#10B981', 'volunteer_activism',   5),
  ('jeev_daya', 'Jeev Daya',  'Compassion for all living beings — animal welfare and protection of life.',                           '#0D9488', 'eco',                  6)
ON CONFLICT (type) DO NOTHING;

-- Extend the events table created in 004 (idempotent).
ALTER TABLE events ADD COLUMN IF NOT EXISTS updated_by INTEGER REFERENCES members(id);

-- Tie events.vibhag_type to the vibhags catalogue (guarded so re-runs are safe).
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'fk_events_vibhag'
  ) THEN
    ALTER TABLE events
      ADD CONSTRAINT fk_events_vibhag
      FOREIGN KEY (vibhag_type) REFERENCES vibhags(type);
  END IF;
END$$;

CREATE TABLE IF NOT EXISTS vibhag_heads (
  id           SERIAL PRIMARY KEY,
  vibhag_type  VARCHAR(30) NOT NULL REFERENCES vibhags(type) ON DELETE CASCADE,
  member_id    INTEGER     NOT NULL REFERENCES members(id)   ON DELETE CASCADE,
  assigned_by  INTEGER     REFERENCES members(id),
  assigned_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (vibhag_type, member_id)
);

CREATE INDEX IF NOT EXISTS idx_vibhag_heads_member ON vibhag_heads(member_id);
CREATE INDEX IF NOT EXISTS idx_vibhag_heads_vibhag ON vibhag_heads(vibhag_type);

CREATE TABLE IF NOT EXISTS event_sponsorships (
  id           SERIAL PRIMARY KEY,
  event_id     INTEGER     NOT NULL REFERENCES events(id)  ON DELETE CASCADE,
  member_id    INTEGER     NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  note         TEXT,
  amount       NUMERIC(12, 2),
  status       VARCHAR(12) NOT NULL DEFAULT 'pending',  -- pending | approved | declined
  decided_by   INTEGER     REFERENCES members(id),
  decided_at   TIMESTAMPTZ,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT chk_sponsorship_status CHECK (status IN ('pending', 'approved', 'declined')),
  UNIQUE (event_id, member_id)
);

CREATE INDEX IF NOT EXISTS idx_sponsorships_event  ON event_sponsorships(event_id);
CREATE INDEX IF NOT EXISTS idx_sponsorships_member ON event_sponsorships(member_id);
CREATE INDEX IF NOT EXISTS idx_events_vibhag        ON events(vibhag_type);
