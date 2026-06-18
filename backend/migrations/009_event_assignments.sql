-- migrations/009_event_assignments.sql
-- Assigned members per event, with an admin-controlled lock. Any member can edit
-- the list while it is open; once locked, only admins may change it.

ALTER TABLE events ADD COLUMN IF NOT EXISTS members_locked     BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE events ADD COLUMN IF NOT EXISTS members_locked_by  INTEGER REFERENCES members(id);
ALTER TABLE events ADD COLUMN IF NOT EXISTS members_locked_at  TIMESTAMPTZ;
ALTER TABLE events ADD COLUMN IF NOT EXISTS members_updated_at TIMESTAMPTZ;

CREATE TABLE IF NOT EXISTS event_assignments (
  id          SERIAL PRIMARY KEY,
  event_id    INTEGER NOT NULL REFERENCES events(id)  ON DELETE CASCADE,
  member_id   INTEGER NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  assigned_by INTEGER REFERENCES members(id),
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (event_id, member_id)
);

CREATE INDEX IF NOT EXISTS idx_assignments_event  ON event_assignments(event_id);
CREATE INDEX IF NOT EXISTS idx_assignments_member ON event_assignments(member_id);
