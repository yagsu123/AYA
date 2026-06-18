// src/middleware/roles.js — role-based access guard. Use after requireAuth.
function requireRole(...roles) {
  return (req, res, next) => {
    // role_status must be 'approved' — a self-requested role pending admin
    // approval must NOT grant admin access.
    if (!req.member || !roles.includes(req.member.role) || req.member.role_status !== 'approved') {
      return res.status(403).json({
        code: 'FORBIDDEN',
        message: 'You do not have permission to perform this action.',
      });
    }
    return next();
  };
}

module.exports = { requireRole };
