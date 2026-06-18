// src/models/dashboardModel.js
const db = require('../config/db');

async function memberHeader(memberId) {
  const { rows } = await db.query(
    `SELECT m.id, m.mobile, m.role, m.role_status,
            p.full_name, p.photo_url,
            COALESCE(p.profile_complete_pct, 0) AS profile_complete_pct
     FROM members m
     LEFT JOIN member_profiles p ON p.member_id = m.id
     WHERE m.id = $1`,
    [memberId]
  );
  return rows[0] || null;
}

async function todayBirthdays() {
  const { rows } = await db.query(
    `SELECT m.id, m.mobile, p.full_name, p.photo_url, p.dob
     FROM members m
     JOIN member_profiles p ON p.member_id = m.id
     WHERE m.status = 'active' AND p.dob IS NOT NULL
       AND EXTRACT(MONTH FROM p.dob) = EXTRACT(MONTH FROM CURRENT_DATE)
       AND EXTRACT(DAY FROM p.dob) = EXTRACT(DAY FROM CURRENT_DATE)
     ORDER BY p.full_name`
  );
  return rows;
}

async function todayAnniversaries() {
  const { rows } = await db.query(
    `SELECT m.id, m.mobile, p.full_name, p.photo_url, p.anniversary_date
     FROM members m
     JOIN member_profiles p ON p.member_id = m.id
     WHERE m.status = 'active' AND p.anniversary_date IS NOT NULL
       AND EXTRACT(MONTH FROM p.anniversary_date) = EXTRACT(MONTH FROM CURRENT_DATE)
       AND EXTRACT(DAY FROM p.anniversary_date) = EXTRACT(DAY FROM CURRENT_DATE)
     ORDER BY p.full_name`
  );
  return rows;
}

async function nextEvent() {
  const { rows } = await db.query(
    `SELECT id, vibhag_type, name, date, time, venue
     FROM events
     WHERE date >= CURRENT_DATE
     ORDER BY date, time NULLS LAST
     LIMIT 1`
  );
  return rows[0] || null;
}

async function activeMembersCount() {
  const { rows } = await db.query(
    `SELECT COUNT(*)::int AS c FROM members WHERE status = 'active'`);
  return rows[0].c;
}

module.exports = {
  memberHeader, todayBirthdays, todayAnniversaries, nextEvent, activeMembersCount,
};
