// src/models/auditModel.js
const db = require('../config/db');

async function log({ actorId = null, action, targetId = null, targetType = null, metadata = null }) {
  await db.query(
    `INSERT INTO audit_logs (actor_id, action, target_id, target_type, metadata)
     VALUES ($1, $2, $3, $4, $5)`,
    [actorId, action, targetId, targetType, metadata ? JSON.stringify(metadata) : null]
  );
}

module.exports = { log };
