// src/controllers/adminController.js — Phase 2: member management.
const memberModel = require('../models/memberModel');
const refreshTokenModel = require('../models/refreshTokenModel');
const auditModel = require('../models/auditModel');
const bcrypt = require('../utils/bcrypt');
const env = require('../config/env');

// POST /api/admin/members
async function addMember(req, res, next) {
  try {
    const { mobile } = req.body;

    const existing = await memberModel.findByMobile(mobile);
    // A previously deleted member can be re-added (reactivated); an active or
    // inactive one is a genuine duplicate.
    if (existing && existing.status !== 'deleted') {
      return res.status(400).json({
        code: 'MOBILE_EXISTS',
        message: 'This mobile number is already registered.',
      });
    }

    const count = await memberModel.countMembers();
    if (count >= memberModel.MEMBER_LIMIT) {
      return res.status(400).json({
        code: 'MEMBER_LIMIT_REACHED',
        message: 'Maximum member limit reached.',
      });
    }

    // Every member signs in with the shared default password; only its bcrypt
    // hash is stored. The admin shares this password with the new member.
    const sharedPassword = env.defaultMemberPassword;
    const passwordHash = await bcrypt.hash(sharedPassword);
    const member = existing
        ? await memberModel.reactivate(mobile, passwordHash)
        : await memberModel.create(mobile, passwordHash);

    await auditModel.log({
      actorId: req.member.id,
      action: 'ADD_MEMBER',
      targetId: member.id,
      targetType: 'member',
      metadata: { mobile, revived: !!existing },
    });

    return res.status(201).json({
      id: member.id,
      mobile: member.mobile,
      tempPassword: sharedPassword,
    });
  } catch (err) {
    return next(err);
  }
}

// GET /api/admin/members?page=1&limit=20
async function listMembers(req, res, next) {
  try {
    const page = Math.max(parseInt(req.query.page || '1', 10), 1);
    const limit = Math.min(Math.max(parseInt(req.query.limit || '20', 10), 1), 100);
    const result = await memberModel.list({ page, limit });
    return res.json(result);
  } catch (err) {
    return next(err);
  }
}

// PATCH /api/admin/members/:id/status
async function updateStatus(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    const { status } = req.body;

    const target = await memberModel.findById(id);
    if (!target) {
      return res.status(404).json({ code: 'MEMBER_NOT_FOUND', message: 'Member not found.' });
    }
    if (target.id === req.member.id) {
      return res.status(400).json({
        code: 'CANNOT_CHANGE_SELF',
        message: 'You cannot change your own status.',
      });
    }

    const updated = await memberModel.updateStatus(id, status);

    // Inactive members must be kicked out: revoke all their refresh tokens.
    if (status === 'inactive') {
      await refreshTokenModel.revokeAllForMember(id);
    }

    await auditModel.log({
      actorId: req.member.id,
      action: 'CHANGE_MEMBER_STATUS',
      targetId: id,
      targetType: 'member',
      metadata: { status },
    });

    return res.json({ id: updated.id, status: updated.status });
  } catch (err) {
    return next(err);
  }
}

// DELETE /api/admin/members/:id  — soft-delete (removed from lists, frees a slot)
async function deleteMember(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    const target = await memberModel.findById(id);
    if (!target) {
      return res.status(404).json({ code: 'MEMBER_NOT_FOUND', message: 'Member not found.' });
    }
    if (target.id === req.member.id) {
      return res.status(400).json({
        code: 'CANNOT_DELETE_SELF',
        message: 'You cannot delete your own account.',
      });
    }

    await memberModel.updateStatus(id, 'deleted');
    await refreshTokenModel.revokeAllForMember(id); // sign them out immediately

    await auditModel.log({
      actorId: req.member.id,
      action: 'DELETE_MEMBER',
      targetId: id,
      targetType: 'member',
      metadata: { mobile: target.mobile },
    });

    return res.json({ id, deleted: true });
  } catch (err) {
    return next(err);
  }
}

// GET /api/admin/stats
async function getStats(req, res, next) {
  try {
    const s = await memberModel.stats();
    return res.json({
      total: s.total,
      active: s.active,
      inactive: s.inactive,
      limit: memberModel.MEMBER_LIMIT,
      remaining: Math.max(memberModel.MEMBER_LIMIT - s.total, 0),
    });
  } catch (err) {
    return next(err);
  }
}

module.exports = { addMember, listMembers, updateStatus, deleteMember, getStats };
