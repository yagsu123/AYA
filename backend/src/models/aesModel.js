// src/models/aesModel.js — single AES content record.
const db = require('../config/db');

async function getContent() {
  const { rows } = await db.query(
    `SELECT id, what_is_aes, history, objectives, donation_contact,
            progress_current, progress_target, updated_at
     FROM aes_content ORDER BY id LIMIT 1`
  );
  return rows[0] || null;
}

async function updateContent(fields) {
  const current = await getContent();
  if (!current) return null;
  const { rows } = await db.query(
    `UPDATE aes_content SET
       what_is_aes      = COALESCE($2, what_is_aes),
       history          = COALESCE($3, history),
       objectives       = COALESCE($4, objectives),
       donation_contact = COALESCE($5, donation_contact),
       progress_current = COALESCE($6, progress_current),
       progress_target  = COALESCE($7, progress_target),
       updated_at       = NOW()
     WHERE id = $1
     RETURNING id, what_is_aes, history, objectives, donation_contact,
               progress_current, progress_target, updated_at`,
    [
      current.id,
      fields.whatIsAes ?? null,
      fields.history ?? null,
      fields.objectives ?? null,
      fields.donationContact ?? null,
      fields.progressCurrent ?? null,
      fields.progressTarget ?? null,
    ]
  );
  return rows[0];
}

module.exports = { getContent, updateContent };
