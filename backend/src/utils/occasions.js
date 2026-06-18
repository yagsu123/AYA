// src/utils/occasions.js — next-occurrence math for birthdays/anniversaries.
// Handles year boundaries (Dec → Jan) and Feb 29 (celebrated Mar 1 in
// non-leap years).

function nextOccurrence(date, from = new Date()) {
  const today = new Date(from.getFullYear(), from.getMonth(), from.getDate());
  let month = date.getMonth();
  let day = date.getDate();

  const isLeap = (y) => (y % 4 === 0 && y % 100 !== 0) || y % 400 === 0;

  const build = (year) => {
    let m = month, d = day;
    if (m === 1 && d === 29 && !isLeap(year)) { m = 2; d = 1; } // Feb 29 → Mar 1
    return new Date(year, m, d);
  };

  let next = build(today.getFullYear());
  if (next < today) next = build(today.getFullYear() + 1);
  return next;
}

function daysUntil(date, from = new Date()) {
  const today = new Date(from.getFullYear(), from.getMonth(), from.getDate());
  const next = nextOccurrence(date, from);
  return Math.round((next - today) / 86400000);
}

/** Age/years they turn on the next occurrence. */
function turningYears(date, from = new Date()) {
  return nextOccurrence(date, from).getFullYear() - date.getFullYear();
}

module.exports = { nextOccurrence, daysUntil, turningYears };
