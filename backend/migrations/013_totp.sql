-- migrations/013_totp.sql
-- Time-based one-time password (authenticator app) enrolment for members.
-- A member sets up an authenticator on their first sign-in: the secret is
-- stored here and `totp_enabled` flips to true once they verify a code.

ALTER TABLE members
  ADD COLUMN IF NOT EXISTS totp_secret  TEXT,
  ADD COLUMN IF NOT EXISTS totp_enabled BOOLEAN NOT NULL DEFAULT FALSE;
