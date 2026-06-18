-- migrations/007_event_end_date.sql
-- Multi-day events: an event may span a date range. end_date is NULL for
-- single-day events; when set it is the (inclusive) last day. Scope filtering
-- treats an event as "upcoming/ongoing" until its last day has passed.

ALTER TABLE events ADD COLUMN IF NOT EXISTS end_date DATE;

CREATE INDEX IF NOT EXISTS idx_events_end_date ON events(end_date);
