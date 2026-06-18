// src/utils/tempPassword.js — crypto-random 8-char temp password.
// Unambiguous alphabet (no 0/O, 1/l/I) so it can be read out over the phone.
const crypto = require('crypto');

const ALPHABET = 'ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789';

function generateTempPassword(length = 8) {
  const bytes = crypto.randomBytes(length);
  let out = '';
  for (let i = 0; i < length; i++) {
    out += ALPHABET[bytes[i] % ALPHABET.length];
  }
  return out;
}

module.exports = { generateTempPassword };
