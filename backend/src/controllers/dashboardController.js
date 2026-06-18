// src/controllers/dashboardController.js
const dashboardModel = require('../models/dashboardModel');
const adsModel = require('../models/adsModel');
const occasionsModel = require('../models/occasionsModel');
const { daysUntil, turningYears } = require('../utils/occasions');

function todayOnly(rows) {
  return rows
    .map((r) => {
      const date = new Date(r.date);
      return {
        id: r.id,
        full_name: r.name,
        photo_url: r.photo_url,
        mobile: r.mobile,
        relation: r.relation,
        via: r.via,
        dob: r.date,
        anniversary_date: r.date,
        years: turningYears(date),
        days_until: daysUntil(date),
      };
    })
    .filter((e) => e.days_until === 0);
}

// GET /api/dashboard
async function getDashboard(req, res, next) {
  try {
    const [member, birthdays, anniversaries, event, ads, membersCount] =
      await Promise.all([
        dashboardModel.memberHeader(req.member.id),
        occasionsModel.allBirthdays().then(todayOnly),
        occasionsModel.allAnniversaries().then(todayOnly),
        dashboardModel.nextEvent(),
        adsModel.list(),
        dashboardModel.activeMembersCount(),
      ]);

    return res.json({
      member: {
        full_name: member.full_name,
        photo_url: member.photo_url,
        mobile: member.mobile,
        role: member.role,
        role_status: member.role_status,
      },
      todayBirthdays: birthdays,
      todayAnniversaries: anniversaries,
      nextEvent: event,
      profileCompletePct: member.profile_complete_pct,
      membersCount,
      ads,
    });
  } catch (err) {
    return next(err);
  }
}

module.exports = { getDashboard };
