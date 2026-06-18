// src/utils/storage.js — photo storage abstraction.
// Uses Google Drive when configured (see drive.js), otherwise saves to
// backend/uploads/ which is served statically at /uploads.
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const drive = require('./drive');

const UPLOADS_ROOT = path.join(__dirname, '..', '..', 'uploads');

/**
 * Store a processed image buffer for a member.
 * Returns { url, driveId } — url is absolute (Drive) or relative (/uploads/...).
 */
async function storeMemberPhoto(buffer, memberId) {
  const filename = `${Date.now()}-${crypto.randomBytes(6).toString('hex')}.webp`;

  if (drive.isConfigured()) {
    return drive.uploadMemberPhoto(buffer, memberId, filename);
  }

  const dir = path.join(UPLOADS_ROOT, 'members', String(memberId));
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(path.join(dir, filename), buffer);
  return { url: `/uploads/members/${memberId}/${filename}`, driveId: null };
}

/**
 * Store a processed image under uploads/<subdir>/ (local mode).
 * Drive mode keeps using the member-photo path for member photos only;
 * ad images stay local for fast serving.
 */
async function storeImage(buffer, subdir) {
  const filename = `${Date.now()}-${crypto.randomBytes(6).toString('hex')}.webp`;
  const dir = path.join(UPLOADS_ROOT, subdir);
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(path.join(dir, filename), buffer);
  return { url: `/uploads/${subdir}/${filename}`, driveId: null };
}

module.exports = { storeMemberPhoto, storeImage, UPLOADS_ROOT };
