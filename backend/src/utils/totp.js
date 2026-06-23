// src/utils/totp.js — authenticator-app (TOTP) helpers.
// Wraps otplib so the rest of the app never depends on the library directly.
const { authenticator } = require('otplib');

// Allow a one-step (±30s) window to tolerate clock drift between the phone
// and the server.
authenticator.options = { window: 1 };

const ISSUER = 'AYA Chennai';

function generateSecret() {
  return authenticator.generateSecret();
}

/**
 * otpauth:// URI that an authenticator app turns into a QR code. The account
 * label is the member's mobile so they can tell entries apart.
 */
function buildOtpAuthUrl(accountName, secret) {
  return authenticator.keyuri(accountName, ISSUER, secret);
}

function verifyToken(token, secret) {
  if (!token || !secret) return false;
  try {
    return authenticator.verify({ token: String(token).trim(), secret });
  } catch (_) {
    return false;
  }
}

module.exports = { generateSecret, buildOtpAuthUrl, verifyToken };
