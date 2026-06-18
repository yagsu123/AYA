// src/utils/drive.js — Google Drive upload (used when credentials are configured).
// Requires env: GOOGLE_SERVICE_ACCOUNT_JSON (path to key file), GOOGLE_DRIVE_ROOT_ID.
const { google } = require('googleapis');

let driveClient = null;

function isConfigured() {
  return !!(process.env.GOOGLE_SERVICE_ACCOUNT_JSON && process.env.GOOGLE_DRIVE_ROOT_ID);
}

function getClient() {
  if (!driveClient) {
    const auth = new google.auth.GoogleAuth({
      keyFile: process.env.GOOGLE_SERVICE_ACCOUNT_JSON,
      scopes: ['https://www.googleapis.com/auth/drive'],
    });
    driveClient = google.drive({ version: 'v3', auth });
  }
  return driveClient;
}

async function ensureFolder(drive, name, parentId) {
  const q = `name = '${name.replace(/'/g, "\\'")}' and '${parentId}' in parents ` +
            `and mimeType = 'application/vnd.google-apps.folder' and trashed = false`;
  const found = await drive.files.list({ q, fields: 'files(id)' });
  if (found.data.files.length > 0) return found.data.files[0].id;
  const created = await drive.files.create({
    requestBody: { name, parents: [parentId], mimeType: 'application/vnd.google-apps.folder' },
    fields: 'id',
  });
  return created.data.id;
}

/**
 * Upload a buffer to AYA/Members/{memberId}/ on Drive.
 * Returns { url, driveId }.
 */
async function uploadMemberPhoto(buffer, memberId, filename) {
  const drive = getClient();
  const { Readable } = require('stream');

  const membersFolder = await ensureFolder(drive, 'Members', process.env.GOOGLE_DRIVE_ROOT_ID);
  const memberFolder = await ensureFolder(drive, String(memberId), membersFolder);

  const file = await drive.files.create({
    requestBody: { name: filename, parents: [memberFolder] },
    media: { mimeType: 'image/webp', body: Readable.from(buffer) },
    fields: 'id',
  });
  await drive.permissions.create({
    fileId: file.data.id,
    requestBody: { role: 'reader', type: 'anyone' },
  });
  return {
    url: `https://drive.google.com/uc?export=view&id=${file.data.id}`,
    driveId: file.data.id,
  };
}

module.exports = { isConfigured, uploadMemberPhoto };
