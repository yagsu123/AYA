// src/models/profileModel.js — member_profiles + member_children queries.
const db = require('../config/db');

// Whitelist of updatable profile columns — anything else in the body is ignored.
const UPDATABLE = [
  'full_name', 'email', 'dob', 'anniversary_date', 'native_place', 'blood_group',
  'photo_url', 'photo_drive_id',
  'res_address', 'res_phone', 'office_address', 'office_phone',
  'mandal_category', 'mandal_position',
  'spouse_name', 'spouse_mobile', 'spouse_dob', 'spouse_photo_url', 'spouse_photo_drive_id',
];

async function getByMemberId(memberId) {
  const { rows } = await db.query(
    'SELECT * FROM member_profiles WHERE member_id = $1', [memberId]);
  return rows[0] || null;
}

async function getChildren(memberId) {
  const { rows } = await db.query(
    `SELECT id, name, dob, contact, photo_url, sort_order
     FROM member_children WHERE member_id = $1
     ORDER BY sort_order, id`, [memberId]);
  return rows;
}

/** Partial upsert: only the provided whitelisted fields are written. */
async function upsert(memberId, fields) {
  const keys = Object.keys(fields).filter((k) => UPDATABLE.includes(k));

  if (keys.length === 0) {
    // Still ensure a row exists.
    await db.query(
      `INSERT INTO member_profiles (member_id) VALUES ($1)
       ON CONFLICT (member_id) DO NOTHING`, [memberId]);
    return getByMemberId(memberId);
  }

  const cols = keys.join(', ');
  const placeholders = keys.map((_, i) => `$${i + 2}`).join(', ');
  const updates = keys.map((k, i) => `${k} = $${i + 2}`).join(', ');
  const values = keys.map((k) => (fields[k] === '' ? null : fields[k]));

  const { rows } = await db.query(
    `INSERT INTO member_profiles (member_id, ${cols})
     VALUES ($1, ${placeholders})
     ON CONFLICT (member_id)
     DO UPDATE SET ${updates}, updated_at = NOW()
     RETURNING *`,
    [memberId, ...values]
  );
  return rows[0];
}

async function setCompletionPct(memberId, pct) {
  await db.query(
    `UPDATE member_profiles SET profile_complete_pct = $2, updated_at = NOW()
     WHERE member_id = $1`, [memberId, pct]);
}

async function addChild(memberId, { name, dob, contact, photo_url, sort_order }) {
  const { rows } = await db.query(
    `INSERT INTO member_children (member_id, name, dob, contact, photo_url, sort_order)
     VALUES ($1, $2, $3, $4, $5, COALESCE($6, 0))
     RETURNING id, name, dob, contact, photo_url, sort_order`,
    [memberId, name, dob || null, contact || null, photo_url || null, sort_order]
  );
  return rows[0];
}

async function updateChild(memberId, childId, { name, dob, contact, photo_url }) {
  const { rows } = await db.query(
    `UPDATE member_children
     SET name = COALESCE($3, name),
         dob = COALESCE($4, dob),
         contact = COALESCE($5, contact),
         photo_url = COALESCE($6, photo_url)
     WHERE id = $2 AND member_id = $1
     RETURNING id, name, dob, contact, photo_url, sort_order`,
    [memberId, childId, name, dob, contact, photo_url]
  );
  return rows[0] || null;
}

async function deleteChild(memberId, childId) {
  const { rowCount } = await db.query(
    'DELETE FROM member_children WHERE id = $2 AND member_id = $1',
    [memberId, childId]
  );
  return rowCount > 0;
}

async function setRole(memberId, role, roleStatus) {
  const { rows } = await db.query(
    `UPDATE members SET role = $2, role_status = $3, updated_at = NOW()
     WHERE id = $1 RETURNING id, role, role_status`,
    [memberId, role, roleStatus]
  );
  return rows[0];
}

module.exports = {
  getByMemberId, getChildren, upsert, setCompletionPct,
  addChild, updateChild, deleteChild, setRole,
};
