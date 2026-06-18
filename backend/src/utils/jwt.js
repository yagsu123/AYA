// src/utils/jwt.js — access + refresh token helpers.
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const env = require('../config/env');

const ACCESS_EXPIRES = '7d';
const REFRESH_EXPIRES = '30d';
const REFRESH_EXPIRES_MS = 30 * 24 * 60 * 60 * 1000;

function signAccessToken(member) {
  return jwt.sign(
    { id: member.id, mobile: member.mobile, role: member.role },
    env.jwtSecret,
    { expiresIn: ACCESS_EXPIRES }
  );
}

function signRefreshToken(member) {
  return jwt.sign(
    { id: member.id, type: 'refresh', jti: crypto.randomUUID() },
    env.jwtRefreshSecret,
    { expiresIn: REFRESH_EXPIRES }
  );
}

function verifyAccessToken(token) {
  return jwt.verify(token, env.jwtSecret);
}

function verifyRefreshToken(token) {
  return jwt.verify(token, env.jwtRefreshSecret);
}

module.exports = {
  signAccessToken,
  signRefreshToken,
  verifyAccessToken,
  verifyRefreshToken,
  REFRESH_EXPIRES_MS,
};
