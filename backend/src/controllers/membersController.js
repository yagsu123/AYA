// src/controllers/membersController.js — read-only member directory.
const memberModel = require('../models/memberModel');

// GET /api/members  → active members (for assignment pickers). Any auth member.
async function directory(req, res, next) {
  try {
    const items = await memberModel.listActiveDirectory();
    return res.json({ items });
  } catch (err) {
    return next(err);
  }
}

module.exports = { directory };
