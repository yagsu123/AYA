// src/models/adsModel.js
const db = require('../config/db');

const ADS_LIMIT = 5;

async function list() {
  const { rows } = await db.query(
    'SELECT id, title, image_url, link_url, sort_order FROM ads ORDER BY sort_order, id'
  );
  return rows;
}

async function count() {
  const { rows } = await db.query('SELECT COUNT(*)::int AS c FROM ads');
  return rows[0].c;
}

async function create({ title, imageUrl, linkUrl, createdBy }) {
  const { rows } = await db.query(
    `INSERT INTO ads (title, image_url, link_url, created_by)
     VALUES ($1, $2, $3, $4)
     RETURNING id, title, image_url, link_url, sort_order`,
    [title || null, imageUrl, linkUrl || null, createdBy]
  );
  return rows[0];
}

async function update(id, { title, linkUrl, sortOrder }) {
  const { rows } = await db.query(
    `UPDATE ads SET
       title = COALESCE($2, title),
       link_url = COALESCE($3, link_url),
       sort_order = COALESCE($4, sort_order)
     WHERE id = $1
     RETURNING id, title, image_url, link_url, sort_order`,
    [id, title, linkUrl, sortOrder]
  );
  return rows[0] || null;
}

async function remove(id) {
  const { rowCount } = await db.query('DELETE FROM ads WHERE id = $1', [id]);
  return rowCount > 0;
}

module.exports = { ADS_LIMIT, list, count, create, update, remove };
