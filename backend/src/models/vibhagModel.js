// src/models/vibhagModel.js — the six vibhags, their heads, and head lookups.
const db = require('../config/db');

const MEMBER_NAME = "COALESCE(NULLIF(p.full_name, ''), m.mobile)";

/** All vibhags with head + upcoming-event counts, ordered for display. */
async function list() {
  const { rows } = await db.query(
    `SELECT v.type, v.name, v.description, v.color, v.icon, v.sort_order,
            (SELECT COUNT(*)::int FROM vibhag_heads h WHERE h.vibhag_type = v.type)
              AS head_count,
            (SELECT COUNT(*)::int FROM events e
              WHERE e.vibhag_type = v.type AND e.date >= CURRENT_DATE)
              AS upcoming_count
     FROM vibhags v
     ORDER BY v.sort_order, v.name`
  );
  return rows;
}

async function findByType(type) {
  const { rows } = await db.query(
    `SELECT type, name, description, color, icon, sort_order
     FROM vibhags WHERE type = $1`,
    [type]
  );
  return rows[0] || null;
}

async function update(type, { name, description, color, icon }) {
  const { rows } = await db.query(
    `UPDATE vibhags
     SET name        = COALESCE($2, name),
         description = COALESCE($3, description),
         color       = COALESCE($4, color),
         icon        = COALESCE($5, icon),
         updated_at  = NOW()
     WHERE type = $1
     RETURNING type, name, description, color, icon, sort_order`,
    [type, name ?? null, description ?? null, color ?? null, icon ?? null]
  );
  return rows[0] || null;
}

/** Members appointed to a vibhag, with display name / mobile / photo. */
async function listHeads(type) {
  const { rows } = await db.query(
    `SELECT h.id, h.member_id, h.assigned_at,
            ${MEMBER_NAME} AS full_name, m.mobile, p.photo_url, m.role
     FROM vibhag_heads h
     JOIN members m ON m.id = h.member_id
     LEFT JOIN member_profiles p ON p.member_id = m.id
     WHERE h.vibhag_type = $1
     ORDER BY ${MEMBER_NAME}`,
    [type]
  );
  return rows;
}

/** Vibhag types a member heads (used to show manage affordances in the app). */
async function typesHeadedBy(memberId) {
  const { rows } = await db.query(
    `SELECT vibhag_type FROM vibhag_heads WHERE member_id = $1`,
    [memberId]
  );
  return rows.map((r) => r.vibhag_type);
}

async function isHead(memberId, type) {
  const { rows } = await db.query(
    `SELECT 1 FROM vibhag_heads WHERE member_id = $1 AND vibhag_type = $2 LIMIT 1`,
    [memberId, type]
  );
  return rows.length > 0;
}

async function addHead(type, memberId, assignedBy) {
  const { rows } = await db.query(
    `INSERT INTO vibhag_heads (vibhag_type, member_id, assigned_by)
     VALUES ($1, $2, $3)
     ON CONFLICT (vibhag_type, member_id) DO NOTHING
     RETURNING id`,
    [type, memberId, assignedBy]
  );
  return rows[0] || null; // null when the member was already a head
}

async function removeHead(type, memberId) {
  const { rowCount } = await db.query(
    `DELETE FROM vibhag_heads WHERE vibhag_type = $1 AND member_id = $2`,
    [type, memberId]
  );
  return rowCount > 0;
}

module.exports = {
  list,
  findByType,
  update,
  listHeads,
  typesHeadedBy,
  isHead,
  addHead,
  removeHead,
};
