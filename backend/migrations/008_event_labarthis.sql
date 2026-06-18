-- migrations/008_event_labarthis.sql
-- Labarthi (beneficiary) records are now entered BY members for an event, with
-- a private contribution amount. This replaces the public self-signup model
-- (event_sponsorships). Events also gain a separate end time.

ALTER TABLE events ADD COLUMN IF NOT EXISTS end_time TIME;

CREATE TABLE IF NOT EXISTS event_labarthis (
  id          SERIAL PRIMARY KEY,
  event_id    INTEGER     NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  name        VARCHAR(150) NOT NULL,
  amount      NUMERIC(12, 2),          -- private; visible only to authorised users
  note        TEXT,
  added_by    INTEGER     REFERENCES members(id),
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_labarthis_event ON event_labarthis(event_id);

-- Retire the public self-signup table; members no longer self-register.
DROP TABLE IF EXISTS event_sponsorships;
