// src/middleware/audit.js — writes an audit log row for every POST/PATCH/DELETE.
// Never logs request bodies (they may contain passwords) — only safe metadata.
const auditModel = require('../models/auditModel');

function auditLogger(req, res, next) {
  const method = req.method.toUpperCase();
  if (!['POST', 'PATCH', 'DELETE', 'PUT'].includes(method)) return next();

  res.on('finish', () => {
    const actorId = req.member ? req.member.id : (req.auditActorId || null);
    auditModel
      .log({
        actorId,
        action: `${method} ${req.originalUrl.split('?')[0]}`,
        metadata: { status: res.statusCode, ip: req.ip },
      })
      .catch((err) => console.error('Audit log failed:', err.message));
  });

  return next();
}

module.exports = { auditLogger };
