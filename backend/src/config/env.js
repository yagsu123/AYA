// src/config/env.js — central, validated environment access.
require('dotenv').config();

const required = ['DATABASE_URL', 'JWT_SECRET', 'JWT_REFRESH_SECRET'];
const missing = required.filter((k) => !process.env[k]);
if (missing.length > 0) {
  // Fail fast — never run with missing secrets.
  console.error(`Missing required environment variables: ${missing.join(', ')}`);
  process.exit(1);
}

module.exports = {
  databaseUrl: process.env.DATABASE_URL,
  jwtSecret: process.env.JWT_SECRET,
  jwtRefreshSecret: process.env.JWT_REFRESH_SECRET,
  port: parseInt(process.env.PORT || '3000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  // Shared password assigned to every member added by an admin. The admin
  // shares this with the member so they can sign in. Override via .env.
  defaultMemberPassword: process.env.DEFAULT_MEMBER_PASSWORD || 'Ayas@Jin24',
  allowedOrigins: (process.env.ALLOWED_ORIGINS || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean),
};
