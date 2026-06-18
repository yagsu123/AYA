// src/middleware/vibhagAccess.js — admin-role helper.
// Event management is open to any authenticated member (project policy), so no
// per-vibhag manage check is needed. isAdmin is still used to flag admins in
// the vibhags response and could gate future admin-only governance actions.
const ADMIN_ROLES = ['president', 'secretary'];

function isAdmin(member) {
  return (
    !!member &&
    ADMIN_ROLES.includes(member.role) &&
    member.role_status === 'approved'
  );
}

module.exports = { isAdmin, ADMIN_ROLES };
