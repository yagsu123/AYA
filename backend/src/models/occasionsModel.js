// src/models/occasionsModel.js — birthday sources: member + spouse + children.
const db = require('../config/db');

/** All birthday rows across the community (member, spouse, children). */
async function allBirthdays() {
  const { rows } = await db.query(
    `SELECT m.id AS id, p.full_name AS name, p.photo_url, m.mobile,
            p.dob AS date, 'member' AS relation, NULL AS via
     FROM members m
     JOIN member_profiles p ON p.member_id = m.id
     WHERE m.status = 'active' AND p.dob IS NOT NULL

     UNION ALL

     SELECT m.id, p.spouse_name, p.spouse_photo_url,
            COALESCE(NULLIF(p.spouse_mobile, ''), m.mobile),
            p.spouse_dob, 'spouse', p.full_name
     FROM members m
     JOIN member_profiles p ON p.member_id = m.id
     WHERE m.status = 'active' AND p.spouse_dob IS NOT NULL
       AND p.spouse_name IS NOT NULL

     UNION ALL

     SELECT c.id, c.name, c.photo_url,
            COALESCE(NULLIF(c.contact, ''), m.mobile),
            c.dob, 'child', p.full_name
     FROM member_children c
     JOIN members m ON m.id = c.member_id
     LEFT JOIN member_profiles p ON p.member_id = m.id
     WHERE m.status = 'active' AND c.dob IS NOT NULL`
  );
  return rows;
}

/** Anniversaries are couple-level — one entry per member. */
async function allAnniversaries() {
  const { rows } = await db.query(
    `SELECT m.id, p.full_name AS name, p.photo_url, m.mobile,
            p.anniversary_date AS date, 'member' AS relation, p.spouse_name AS via
     FROM members m
     JOIN member_profiles p ON p.member_id = m.id
     WHERE m.status = 'active' AND p.anniversary_date IS NOT NULL`
  );
  return rows;
}

module.exports = { allBirthdays, allAnniversaries };
