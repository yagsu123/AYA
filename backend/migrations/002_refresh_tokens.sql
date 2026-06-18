-- migrations/002_refresh_tokens.sql
-- Required in Phase 1 so POST /api/auth/logout can invalidate refresh tokens.
-- Tokens are stored as SHA-256 hashes, never in plain text.

CREATE TABLE IF NOT EXISTS refresh_tokens (
  id         SERIAL PRIMARY KEY,
  member_id  INTEGER REFERENCES members(id),
  token_hash TEXT NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  revoked    BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_member ON refresh_tokens(member_id);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_hash ON refresh_tokens(token_hash);
