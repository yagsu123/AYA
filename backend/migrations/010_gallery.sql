-- migrations/010_gallery.sql
-- Photo gallery: albums of community/event photos.

CREATE TABLE IF NOT EXISTS gallery_albums (
  id          SERIAL PRIMARY KEY,
  title       VARCHAR(150) NOT NULL,
  description TEXT,
  event_id    INTEGER REFERENCES events(id) ON DELETE SET NULL,
  cover_url   TEXT,
  created_by  INTEGER REFERENCES members(id),
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS gallery_photos (
  id          SERIAL PRIMARY KEY,
  album_id    INTEGER NOT NULL REFERENCES gallery_albums(id) ON DELETE CASCADE,
  image_url   TEXT NOT NULL,
  caption     VARCHAR(200),
  uploaded_by INTEGER REFERENCES members(id),
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_gallery_photos_album ON gallery_photos(album_id);
CREATE INDEX IF NOT EXISTS idx_gallery_albums_event ON gallery_albums(event_id);
