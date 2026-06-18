// src/controllers/occasionsController.js — birthdays + anniversaries
// (members, spouses and children all included for birthdays).
const occasionsModel = require('../models/occasionsModel');
const { daysUntil, turningYears, nextOccurrence } = require('../utils/occasions');

function enrich(rows) {
  return rows.map((r) => {
    const date = new Date(r.date);
    return {
      id: r.id,
      full_name: r.name,
      photo_url: r.photo_url,
      mobile: r.mobile,
      relation: r.relation,          // member | spouse | child
      via: r.via,                    // related member's name (spouse/child)
      date: r.date,
      days_until: daysUntil(date),
      years: turningYears(date),
      next_occurrence: nextOccurrence(date).toISOString().substring(0, 10),
    };
  });
}

function applyFilter(items, filter, days) {
  const filtered = filter === 'today'
    ? items.filter((e) => e.days_until === 0)
    : items.filter((e) => e.days_until > 0 && e.days_until <= days);
  filtered.sort((a, b) => a.days_until - b.days_until ||
    (a.full_name || '').localeCompare(b.full_name || ''));
  return filtered;
}

function parseQuery(req) {
  const filter = req.query.filter === 'today' ? 'today' : 'upcoming';
  const days = Math.min(Math.max(parseInt(req.query.days || '30', 10), 1), 365);
  return { filter, days };
}

// GET /api/birthdays?filter=today|upcoming&days=30
async function birthdays(req, res, next) {
  try {
    const { filter, days } = parseQuery(req);
    const items = applyFilter(enrich(await occasionsModel.allBirthdays()), filter, days);
    return res.json({ filter, days, items });
  } catch (err) {
    return next(err);
  }
}

// GET /api/anniversaries?filter=today|upcoming&days=30
async function anniversaries(req, res, next) {
  try {
    const { filter, days } = parseQuery(req);
    const items = applyFilter(enrich(await occasionsModel.allAnniversaries()), filter, days);
    return res.json({ filter, days, items });
  } catch (err) {
    return next(err);
  }
}

module.exports = { birthdays, anniversaries };
