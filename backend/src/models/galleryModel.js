// src/models/galleryModel.js — photo albums and their photos.
const db = require('../config/db');

const MEMBER_NAME = "COALESCE(NULLIF(p.full_name, ''), m.mobile)";

/** Albums with a cover (explicit, else newest photo) and photo count. */
async function listAlbums() {
  const { rows } = await db.query(
    `SELECT a.id, a.title, a.description, a.event_id, a.created_by, a.created_at,
            COALESCE(a.year, EXTRACT(YEAR FROM a.created_at)::int) AS year,
            COALESCE(a.cover_url,
              (SELECT image_url FROM gallery_photos gp
                 WHERE gp.album_id = a.id ORDER BY gp.created_at DESC LIMIT 1))
              AS cover_url,
            (SELECT COUNT(*)::int FROM gallery_photos gp WHERE gp.album_id = a.id)
              AS photo_count
     FROM gallery_albums a
     ORDER BY year DESC, a.created_at DESC`
  );
  return rows;
}

async function findAlbumById(id) {
  const { rows } = await db.query(
    `SELECT id, title, description, event_id, cover_url, created_by, created_at
     FROM gallery_albums WHERE id = $1`,
    [id]
  );
  return rows[0] || null;
}

async function createAlbum({ title, description, eventId, year, createdBy }) {
  const { rows } = await db.query(
    `INSERT INTO gallery_albums (title, description, event_id, year, created_by)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING id, title, description, event_id, year, cover_url, created_by, created_at`,
    [title, description || null, eventId || null,
      year || new Date().getFullYear(), createdBy]
  );
  return rows[0];
}

async function removeAlbum(id) {
  const { rowCount } = await db.query('DELETE FROM gallery_albums WHERE id = $1', [id]);
  return rowCount > 0;
}

async function listPhotos(albumId) {
  const { rows } = await db.query(
    `SELECT ph.id, ph.album_id, ph.image_url, ph.caption, ph.uploaded_by,
            ph.created_at, ${MEMBER_NAME} AS uploaded_by_name
     FROM gallery_photos ph
     LEFT JOIN members m ON m.id = ph.uploaded_by
     LEFT JOIN member_profiles p ON p.member_id = m.id
     WHERE ph.album_id = $1
     ORDER BY ph.created_at DESC`,
    [albumId]
  );
  return rows;
}

async function addPhoto({ albumId, imageUrl, caption, uploadedBy }) {
  const { rows } = await db.query(
    `INSERT INTO gallery_photos (album_id, image_url, caption, uploaded_by)
     VALUES ($1, $2, $3, $4)
     RETURNING id, album_id, image_url, caption, uploaded_by, created_at`,
    [albumId, imageUrl, caption || null, uploadedBy]
  );
  return rows[0];
}

async function findPhotoById(id) {
  const { rows } = await db.query(
    'SELECT id, album_id, uploaded_by FROM gallery_photos WHERE id = $1',
    [id]
  );
  return rows[0] || null;
}

async function removePhoto(id) {
  const { rowCount } = await db.query('DELETE FROM gallery_photos WHERE id = $1', [id]);
  return rowCount > 0;
}

module.exports = {
  listAlbums,
  findAlbumById,
  createAlbum,
  removeAlbum,
  listPhotos,
  addPhoto,
  findPhotoById,
  removePhoto,
};
