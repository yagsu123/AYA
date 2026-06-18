// src/controllers/authController.js
const memberModel = require('../models/memberModel');
const refreshTokenModel = require('../models/refreshTokenModel');
const auditModel = require('../models/auditModel');
const bcrypt = require('../utils/bcrypt');
const {
  signAccessToken,
  signRefreshToken,
  verifyRefreshToken,
  REFRESH_EXPIRES_MS,
} = require('../utils/jwt');

function publicMember(m) {
  return { id: m.id, mobile: m.mobile, role: m.role };
}

async function issueTokens(member) {
  const token = signAccessToken(member);
  const refreshToken = signRefreshToken(member);
  const expiresAt = new Date(Date.now() + REFRESH_EXPIRES_MS);
  await refreshTokenModel.save(member.id, refreshToken, expiresAt);
  return { token, refreshToken };
}

// POST /api/auth/login
async function login(req, res, next) {
  try {
    const { mobile, password } = req.body;

    // 1. mobile exists → 404 if not
    const member = await memberModel.findByMobile(mobile);
    if (!member) {
      return res.status(404).json({ code: 'MOBILE_NOT_FOUND', message: 'Mobile number not found' });
    }

    // 2. active → 403 if not
    if (member.status !== 'active') {
      return res.status(403).json({
        code: 'ACCOUNT_INACTIVE',
        message: 'Account is inactive. Contact administrator.',
      });
    }

    // 3. password → 401 if wrong
    const ok = await bcrypt.compare(password, member.password_hash);
    if (!ok) {
      return res.status(401).json({ code: 'INCORRECT_PASSWORD', message: 'Incorrect password' });
    }

    // 4–6. issue JWT (7d) + refresh token (30d)
    const { token, refreshToken } = await issueTokens(member);

    req.auditActorId = member.id; // so audit middleware attributes this request
    await auditModel.log({
      actorId: member.id,
      action: 'LOGIN',
      targetId: member.id,
      targetType: 'member',
    });

    return res.json({ token, refreshToken, member: publicMember(member) });
  } catch (err) {
    return next(err);
  }
}

// POST /api/auth/refresh
async function refresh(req, res, next) {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) {
      return res.status(400).json({ code: 'VALIDATION_ERROR', message: 'refreshToken is required.' });
    }

    let payload;
    try {
      payload = verifyRefreshToken(refreshToken);
    } catch (err) {
      return res.status(401).json({ code: 'INVALID_REFRESH', message: 'Invalid or expired refresh token.' });
    }

    const stored = await refreshTokenModel.findValid(refreshToken);
    if (!stored || stored.member_id !== payload.id) {
      return res.status(401).json({ code: 'INVALID_REFRESH', message: 'Refresh token revoked or unknown.' });
    }

    const member = await memberModel.findById(payload.id);
    if (!member) {
      return res.status(401).json({ code: 'INVALID_REFRESH', message: 'Member no longer exists.' });
    }
    if (member.status !== 'active') {
      return res.status(403).json({
        code: 'ACCOUNT_INACTIVE',
        message: 'Account is inactive. Contact administrator.',
      });
    }

    // Rotate: revoke the used refresh token, issue a fresh pair.
    await refreshTokenModel.revoke(refreshToken);
    const tokens = await issueTokens(member);

    return res.json({ ...tokens, member: publicMember(member) });
  } catch (err) {
    return next(err);
  }
}

// POST /api/auth/logout  (protected) — invalidates the supplied refresh token.
async function logout(req, res, next) {
  try {
    const { refreshToken } = req.body;
    if (refreshToken) {
      await refreshTokenModel.revoke(refreshToken);
    } else {
      // No token supplied — revoke everything for this member to be safe.
      await refreshTokenModel.revokeAllForMember(req.member.id);
    }

    await auditModel.log({
      actorId: req.member.id,
      action: 'LOGOUT',
      targetId: req.member.id,
      targetType: 'member',
    });

    return res.json({ success: true });
  } catch (err) {
    return next(err);
  }
}

// GET /api/auth/me  (protected)
async function me(req, res) {
  const m = req.member;
  return res.json({
    member: { id: m.id, mobile: m.mobile, role: m.role, role_status: m.role_status, status: m.status },
  });
}

module.exports = { login, refresh, logout, me };
