// src/controllers/authController.js
const memberModel = require('../models/memberModel');
const refreshTokenModel = require('../models/refreshTokenModel');
const auditModel = require('../models/auditModel');
const bcrypt = require('../utils/bcrypt');
const totp = require('../utils/totp');
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

/**
 * Validates mobile → active account → password. Shared by login and the
 * authenticator-verify endpoint so the credential rules live in one place.
 * Returns `{ member }` on success or `{ error: { status, code, message } }`.
 */
async function authenticate(mobile, password) {
  const member = await memberModel.findByMobile(mobile);
  if (!member) {
    return { error: { status: 404, code: 'MOBILE_NOT_FOUND', message: 'Mobile number not found' } };
  }
  if (member.status !== 'active') {
    return {
      error: { status: 403, code: 'ACCOUNT_INACTIVE', message: 'Account is inactive. Contact administrator.' },
    };
  }
  const passwordMatches = await bcrypt.compare(password, member.password_hash);
  if (!passwordMatches) {
    return { error: { status: 401, code: 'INCORRECT_PASSWORD', message: 'Incorrect password' } };
  }
  return { member };
}

/** Issues tokens, records the LOGIN audit entry, and returns the response. */
async function completeLogin(req, res, member) {
  const { token, refreshToken } = await issueTokens(member);
  req.auditActorId = member.id; // so audit middleware attributes this request
  await auditModel.log({
    actorId: member.id,
    action: 'LOGIN',
    targetId: member.id,
    targetType: 'member',
  });
  return res.json({ token, refreshToken, member: publicMember(member) });
}

// POST /api/auth/login
async function login(req, res, next) {
  try {
    const { mobile, password } = req.body;
    const { member, error } = await authenticate(mobile, password);
    if (error) {
      return res.status(error.status).json({ code: error.code, message: error.message });
    }

    // First sign-in: the member must enrol an authenticator before any token
    // is issued. The secret is generated once and reused across attempts so
    // the QR code stays stable until enrolment is confirmed.
    if (!member.totp_enabled) {
      let secret = member.totp_secret;
      if (!secret) {
        secret = totp.generateSecret();
        await memberModel.setTotpSecret(member.id, secret);
      }
      return res.json({
        totpSetupRequired: true,
        otpauthUrl: totp.buildOtpAuthUrl(member.mobile, secret),
        secret,
      });
    }

    return completeLogin(req, res, member);
  } catch (err) {
    return next(err);
  }
}

// POST /api/auth/totp/verify — confirms first-login authenticator enrolment.
async function verifyTotpSetup(req, res, next) {
  try {
    const { mobile, password, token } = req.body;
    const { member, error } = await authenticate(mobile, password);
    if (error) {
      return res.status(error.status).json({ code: error.code, message: error.message });
    }

    // Already enrolled (e.g. a stale setup screen) — just sign them in.
    if (member.totp_enabled) {
      return completeLogin(req, res, member);
    }

    if (!member.totp_secret || !totp.verifyToken(token, member.totp_secret)) {
      return res.status(401).json({
        code: 'INVALID_OTP',
        message: 'Invalid authenticator code. Please try again.',
      });
    }

    await memberModel.enableTotp(member.id);
    return completeLogin(req, res, member);
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

module.exports = { login, verifyTotpSetup, refresh, logout, me };
