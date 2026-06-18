// src/models/memberModel.js — parameterized member queries.
const db = require('../config/db');

const MEMBER_LIMIT = 81;

async function findByMobile(mobile) {
  const { rows } = await db.query(
    'SELECT id, mobile, password_hash, role, role_status, status FROM members WHERE mobile = $1',
    [mobile]
  );
  return rows[0] || null;
}

async function findById(id) {
  const { rows } = await db.query(
    'SELECT id, mobile, role, role_status, status FROM members WHERE id = $1',
    [id]
  );
  return rows[0] || null;
}

async function create(mobile, passwordHash) {
  const { rows } = await db.query(
    `INSERT INTO members (mobile, password_hash, status)
     VALUES ($1, $2, 'active')
     RETURNING id, mobile, role, status, created_at`,
    [mobile, passwordHash]
  );
  return rows[0];
}

async function list({ page = 1, limit = 20 }) {
  const offset = (page - 1) * limit;
  const [items, count] = await Promise.all([
    db.query(
      `SELECT id, mobile, role, role_status, status, created_at
       FROM members
       WHERE status != 'deleted'
       ORDER BY created_at DESC, id DESC
       LIMIT $1 OFFSET $2`,
      [limit, offset]
    ),
    db.query(`SELECT COUNT(*)::int AS total FROM members WHERE status != 'deleted'`),
  ]);
  return { items: items.rows, total: count.rows[0].total, page, limit };
}

/** Reactivate a soft-deleted member with a fresh password (re-add same number). */
async function reactivate(mobile, passwordHash) {
  const { rows } = await db.query(
    `UPDATE members
     SET status = 'active', role = 'member', role_status = 'approved',
         password_hash = $2, updated_at = NOW()
     WHERE mobile = $1
     RETURNING id, mobile, role, status, created_at`,
    [mobile, passwordHash]
  );
  return rows[0] || null;
}

async function countMembers() {
  const { rows } = await db.query(
    `SELECT COUNT(*)::int AS total FROM members WHERE status != 'deleted'`
  );
  return rows[0].total;
}

async function stats() {
  const { rows } = await db.query(
    `SELECT
       COUNT(*) FILTER (WHERE status != 'deleted')::int AS total,
       COUNT(*) FILTER (WHERE status = 'active')::int   AS active,
       COUNT(*) FILTER (WHERE status = 'inactive')::int AS inactive
     FROM members`
  );
  return rows[0];
}

async function updateStatus(id, status) {
  const { rows } = await db.query(
    `UPDATE members SET status = $2, updated_at = NOW()
     WHERE id = $1
     RETURNING id, mobile, status`,
    [id, status]
  );
  return rows[0] || null;
}

/** Active members with display names — used for member pickers (assignments). */
async function listActiveDirectory() {
  const { rows } = await db.query(
    `SELECT m.id, m.mobile,
            COALESCE(NULLIF(p.full_name, ''), m.mobile) AS full_name,
            p.photo_url
     FROM members m
     LEFT JOIN member_profiles p ON p.member_id = m.id
     WHERE m.status = 'active'
     ORDER BY COALESCE(NULLIF(p.full_name, ''), m.mobile)`
  );
  return rows;
}

module.exports = {
  MEMBER_LIMIT,
  findByMobile,
  findById,
  create,
  list,
  countMembers,
  stats,
  updateStatus,
  reactivate,
  listActiveDirectory,
};
