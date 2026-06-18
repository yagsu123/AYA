-- migrations/005_ads.sql

CREATE TABLE IF NOT EXISTS ads (
  id          SERIAL PRIMARY KEY,
  title       VARCHAR(150),
  image_url   TEXT NOT NULL,
  link_url    TEXT,
  sort_order  INTEGER DEFAULT 0,
  created_by  INTEGER REFERENCES members(id),
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
