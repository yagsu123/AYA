-- migrations/012_aes.sql
-- Aradhana Education Society (AES) content — a single editable record.

CREATE TABLE IF NOT EXISTS aes_content (
  id                SERIAL PRIMARY KEY,
  what_is_aes       TEXT,
  history           TEXT,
  objectives        TEXT,
  donation_contact  VARCHAR(15),
  progress_current  DECIMAL(12, 2) DEFAULT 0,
  progress_target   DECIMAL(12, 2) DEFAULT 0,
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

-- Seed one row if the table is empty (idempotent across migration re-runs).
INSERT INTO aes_content (what_is_aes, history, objectives, donation_contact)
SELECT
  'Aradhana Education Society (AES) supports the education of children and youth in our community.',
  'AES was started by the Aradhana Youth Association to extend its work beyond events into education and welfare.',
  'Provide scholarships, learning materials and mentorship to deserving students of the community.',
  '9876767676'
WHERE NOT EXISTS (SELECT 1 FROM aes_content);
