// src/middleware/auth.js — JWT auth guard for protected routes.
const { verifyAccessToken } = require('../utils/jwt');
const memberModel = require('../models/memberModel');

async function requireAuth(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;

  if (!token) {
    return res.status(401).json({ code: 'NO_TOKEN', message: 'Authentication required.' });
  }

  let payload;
  try {
    payload = verifyAccessToken(token);
  } catch (err) {
    return res.status(401).json({ code: 'INVALID_TOKEN', message: 'Invalid or expired token.' });
  }

  // Always re-check the member in DB so deactivated accounts are kicked out.
  const member = await memberModel.findById(payload.id);
  if (!member) {
    return res.status(401).json({ code: 'INVALID_TOKEN', message: 'Member no longer exists.' });
  }
  if (member.status !== 'active') {
    return res.status(403).json({
      code: 'ACCOUNT_INACTIVE',
      message: 'Account is inactive. Contact administrator.',
    });
  }

  req.member = member;
  return next();
}

module.exports = { requireAuth };
