-- migrations/011_gallery_year.sql
-- Albums are grouped by year in the gallery. Backfill existing albums from
-- their creation date.

ALTER TABLE gallery_albums ADD COLUMN IF NOT EXISTS year INTEGER;

UPDATE gallery_albums
SET year = EXTRACT(YEAR FROM created_at)::int
WHERE year IS NULL;

CREATE INDEX IF NOT EXISTS idx_gallery_albums_year ON gallery_albums(year);
