-- migrations/004_events.sql
-- Events table (Phase 6 schema, created early so the Phase 4 dashboard
-- can show the next upcoming event banner).

CREATE TABLE IF NOT EXISTS events (
  id           SERIAL PRIMARY KEY,
  vibhag_type  VARCHAR(30) NOT NULL,  -- sangeet|seva|aangi|jeev_daya|paryushan|snatra
  name         VARCHAR(150) NOT NULL,
  date         DATE NOT NULL,
  time         TIME,
  venue        VARCHAR(200),
  labarthi     VARCHAR(200),          -- beneficiary/purpose
  description  TEXT,
  created_by   INTEGER REFERENCES members(id),
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_events_date ON events(date);
