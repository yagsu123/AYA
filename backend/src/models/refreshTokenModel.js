// src/models/refreshTokenModel.js — refresh tokens stored as SHA-256 hashes.
const crypto = require('crypto');
const db = require('../config/db');

function hashToken(token) {
  return crypto.createHash('sha256').update(token).digest('hex');
}

async function save(memberId, token, expiresAt) {
  await db.query(
    'INSERT INTO refresh_tokens (member_id, token_hash, expires_at) VALUES ($1, $2, $3)',
    [memberId, hashToken(token), expiresAt]
  );
}

async function findValid(token) {
  const { rows } = await db.query(
    `SELECT id, member_id FROM refresh_tokens
     WHERE token_hash = $1 AND revoked = false AND expires_at > NOW()`,
    [hashToken(token)]
  );
  return rows[0] || null;
}

async function revoke(token) {
  await db.query(
    'UPDATE refresh_tokens SET revoked = true WHERE token_hash = $1',
    [hashToken(token)]
  );
}

async function revokeAllForMember(memberId) {
  await db.query(
    'UPDATE refresh_tokens SET revoked = true WHERE member_id = $1',
    [memberId]
  );
}

module.exports = { save, findValid, revoke, revokeAllForMember };
