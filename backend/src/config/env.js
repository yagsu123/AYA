// src/config/env.js — central, validated environment access.
require('dotenv').config();

const required = ['DATABASE_URL', 'JWT_SECRET', 'JWT_REFRESH_SECRET'];
const missing = required.filter((k) => !process.env[k]);
if (missing.length > 0) {
  // Fail fast — never run with missing secrets.
  console.error(`Missing required environment variables: ${missing.join(', ')}`);
  process.exit(1);
}

// Managed Postgres providers (Supabase, Railway, Render, RDS, …) require a TLS
// connection. Local Postgres does not. We enable SSL for every non-local host
// so the same code works in development and production. `rejectUnauthorized` is
// false because Supabase's connection pooler presents a certificate that is not
// in Node's default trust store; the channel is still encrypted.
function resolveDatabaseSsl(connectionString) {
  const targetsLocalhost = /@(localhost|127\.0\.0\.1)([:/]|$)/.test(
    connectionString || '',
  );
  return targetsLocalhost ? false : { rejectUnauthorized: false };
}

module.exports = {
  databaseUrl: process.env.DATABASE_URL,
  databaseSsl: resolveDatabaseSsl(process.env.DATABASE_URL),
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
