// src/models/eventModel.js — events CRUD plus member-entered labarthi records.
const db = require('../config/db');

const MEMBER_NAME = "COALESCE(NULLIF(p.full_name, ''), m.mobile)";

// Shared event projection: event columns + its vibhag's display data, a labarthi
// count and a NAME-ONLY preview (amounts are never exposed in list payloads).
const EVENT_SELECT = `
  SELECT e.id, e.vibhag_type, e.name, e.date, e.end_date, e.time, e.end_time,
         e.venue, e.description, e.created_by, e.created_at, e.updated_at,
         e.members_locked, e.members_locked_at, e.members_updated_at, e.members_locked_by,
         (SELECT ${MEMBER_NAME} FROM members m LEFT JOIN member_profiles p
            ON p.member_id = m.id WHERE m.id = e.members_locked_by) AS locked_by_name,
         v.name AS vibhag_name, v.color AS vibhag_color, v.icon AS vibhag_icon,
         (SELECT COUNT(*)::int FROM event_assignments a WHERE a.event_id = e.id)
           AS assigned_count,
         (SELECT COUNT(*)::int FROM event_labarthis l WHERE l.event_id = e.id)
           AS labarthi_count,
         (SELECT COALESCE(json_agg(name), '[]'::json) FROM (
            SELECT name FROM event_labarthis
            WHERE event_id = e.id ORDER BY created_at LIMIT 3
         ) preview) AS labarthi_preview
  FROM events e
  JOIN vibhags v ON v.type = e.vibhag_type
`;

/**
 * List events. scope: upcoming (ongoing or future) | past | all.
 * A multi-day event counts as upcoming until its last day (end_date) passes.
 */
async function list({ vibhagType = null, scope = 'upcoming' } = {}) {
  const conditions = [];
  const params = [];

  if (vibhagType) {
    params.push(vibhagType);
    conditions.push(`e.vibhag_type = $${params.length}`);
  }
  if (scope === 'upcoming') conditions.push('COALESCE(e.end_date, e.date) >= CURRENT_DATE');
  else if (scope === 'past') conditions.push('COALESCE(e.end_date, e.date) < CURRENT_DATE');

  const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
  const order = scope === 'past'
    ? 'ORDER BY e.date DESC, e.time DESC NULLS LAST'
    : 'ORDER BY e.date ASC, e.time ASC NULLS LAST';

  const { rows } = await db.query(`${EVENT_SELECT} ${where} ${order}`, params);
  return rows;
}

async function findById(id) {
  const { rows } = await db.query(`${EVENT_SELECT} WHERE e.id = $1`, [id]);
  return rows[0] || null;
}

async function create(
  { vibhagType, name, date, endDate, time, endTime, venue, description, createdBy }
) {
  const { rows } = await db.query(
    `INSERT INTO events
       (vibhag_type, name, date, end_date, time, end_time, venue, description, created_by)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
     RETURNING id`,
    [vibhagType, name, date, endDate || null, time || null, endTime || null,
      venue || null, description || null, createdBy]
  );
  return findById(rows[0].id);
}

async function update(id, { name, date, endDate, time, endTime, venue, description }, updatedBy) {
  const { rows } = await db.query(
    `UPDATE events SET
       name        = COALESCE($2, name),
       date        = COALESCE($3, date),
       end_date    = $4,
       time        = $5,
       end_time    = $6,
       venue       = $7,
       description = $8,
       updated_by  = $9,
       updated_at  = NOW()
     WHERE id = $1
     RETURNING id`,
    [id, name ?? null, date ?? null, endDate || null, time || null, endTime || null,
      venue || null, description || null, updatedBy]
  );
  if (!rows[0]) return null;
  return findById(id);
}

async function remove(id) {
  const { rowCount } = await db.query('DELETE FROM events WHERE id = $1', [id]);
  return rowCount > 0;
}

// ---- Labarthi records (entered by members) ---------------------------------

async function listLabarthis(eventId) {
  const { rows } = await db.query(
    `SELECT l.id, l.event_id, l.name, l.amount, l.note, l.added_by, l.created_at,
            ${MEMBER_NAME} AS added_by_name
     FROM event_labarthis l
     LEFT JOIN members m ON m.id = l.added_by
     LEFT JOIN member_profiles p ON p.member_id = m.id
     WHERE l.event_id = $1
     ORDER BY l.created_at`,
    [eventId]
  );
  return rows;
}

async function addLabarthi({ eventId, name, amount, note, addedBy }) {
  const { rows } = await db.query(
    `INSERT INTO event_labarthis (event_id, name, amount, note, added_by)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING id`,
    [eventId, name, amount ?? null, note || null, addedBy]
  );
  return rows[0];
}

async function findLabarthiById(id) {
  const { rows } = await db.query(
    'SELECT id, event_id FROM event_labarthis WHERE id = $1',
    [id]
  );
  return rows[0] || null;
}

async function removeLabarthi(id) {
  const { rowCount } = await db.query(
    'DELETE FROM event_labarthis WHERE id = $1',
    [id]
  );
  return rowCount > 0;
}

// ---- Assigned members + lock -----------------------------------------------

async function listAssignments(eventId) {
  const { rows } = await db.query(
    `SELECT a.member_id, a.assigned_by, a.created_at,
            ${MEMBER_NAME} AS full_name, m.mobile, p.photo_url
     FROM event_assignments a
     JOIN members m ON m.id = a.member_id
     LEFT JOIN member_profiles p ON p.member_id = m.id
     WHERE a.event_id = $1
     ORDER BY ${MEMBER_NAME}`,
    [eventId]
  );
  return rows;
}

/** Replace the assigned-member set in one transaction; stamps members_updated_at. */
async function setAssignments(eventId, memberIds, actorId) {
  const client = await db.pool.connect();
  try {
    await client.query('BEGIN');
    await client.query('DELETE FROM event_assignments WHERE event_id = $1', [eventId]);
    for (const memberId of memberIds) {
      await client.query(
        `INSERT INTO event_assignments (event_id, member_id, assigned_by)
         VALUES ($1, $2, $3)
         ON CONFLICT (event_id, member_id) DO NOTHING`,
        [eventId, memberId, actorId]
      );
    }
    await client.query(
      'UPDATE events SET members_updated_at = NOW() WHERE id = $1',
      [eventId]
    );
    await client.query('COMMIT');
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
  return listAssignments(eventId);
}

async function lockMembers(eventId, locked, actorId) {
  const { rows } = await db.query(
    `UPDATE events SET
       members_locked = $2,
       members_locked_by = CASE WHEN $2 THEN $3 ELSE members_locked_by END,
       members_locked_at = CASE WHEN $2 THEN NOW() ELSE members_locked_at END
     WHERE id = $1
     RETURNING id`,
    [eventId, locked, actorId]
  );
  if (!rows[0]) return null;
  return findById(eventId);
}

module.exports = {
  list,
  findById,
  create,
  update,
  remove,
  listLabarthis,
  addLabarthi,
  findLabarthiById,
  removeLabarthi,
  listAssignments,
  setAssignments,
  lockMembers,
};
