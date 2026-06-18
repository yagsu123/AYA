// src/controllers/vibhagsController.js — the six vibhags, their heads & events.
const vibhagModel = require('../models/vibhagModel');
const eventModel = require('../models/eventModel');
const memberModel = require('../models/memberModel');
const auditModel = require('../models/auditModel');
const { isAdmin } = require('../middleware/vibhagAccess');

// GET /api/vibhags  → the six vibhags plus what the caller may manage.
async function listVibhags(req, res, next) {
  try {
    const [vibhags, myHeadTypes] = await Promise.all([
      vibhagModel.list(),
      vibhagModel.typesHeadedBy(req.member.id),
    ]);
    return res.json({
      items: vibhags,
      my_head_types: myHeadTypes,
      is_admin: isAdmin(req.member),
    });
  } catch (err) {
    return next(err);
  }
}

// GET /api/vibhags/:type  → vibhag info, heads, upcoming + past events, manage flag.
async function getVibhag(req, res, next) {
  try {
    const { type } = req.params;
    const vibhag = await vibhagModel.findByType(type);
    if (!vibhag) {
      return res.status(404).json({ code: 'VIBHAG_NOT_FOUND', message: 'Vibhag not found.' });
    }

    const [heads, upcoming, past] = await Promise.all([
      vibhagModel.listHeads(type),
      eventModel.list({ vibhagType: type, scope: 'upcoming' }),
      eventModel.list({ vibhagType: type, scope: 'past' }),
    ]);

    // Any authenticated member may manage a vibhag's events (project policy).
    return res.json({ vibhag, heads, upcoming, past, can_manage: true });
  } catch (err) {
    return next(err);
  }
}

// PUT /api/vibhags/:type  (admin only — wired via requireRole in the router)
async function updateVibhag(req, res, next) {
  try {
    const { type } = req.params;
    const updated = await vibhagModel.update(type, {
      name: req.body.name,
      description: req.body.description,
      color: req.body.color,
      icon: req.body.icon,
    });
    if (!updated) {
      return res.status(404).json({ code: 'VIBHAG_NOT_FOUND', message: 'Vibhag not found.' });
    }

    await auditModel.log({
      actorId: req.member.id,
      action: 'UPDATE_VIBHAG',
      targetType: 'vibhag',
      metadata: { type },
    });

    return res.json({ vibhag: updated });
  } catch (err) {
    return next(err);
  }
}

// POST /api/vibhags/:type/heads  { member_id }  (admin only)
async function addHead(req, res, next) {
  try {
    const { type } = req.params;
    const memberId = parseInt(req.body.member_id, 10);

    const vibhag = await vibhagModel.findByType(type);
    if (!vibhag) {
      return res.status(404).json({ code: 'VIBHAG_NOT_FOUND', message: 'Vibhag not found.' });
    }

    const member = await memberModel.findById(memberId);
    if (!member) {
      return res.status(404).json({ code: 'MEMBER_NOT_FOUND', message: 'Member not found.' });
    }
    if (member.status !== 'active') {
      return res.status(400).json({
        code: 'MEMBER_INACTIVE',
        message: 'Only active members can lead a vibhag.',
      });
    }

    const created = await vibhagModel.addHead(type, memberId, req.member.id);
    if (!created) {
      return res.status(409).json({
        code: 'ALREADY_HEAD',
        message: 'This member already leads this vibhag.',
      });
    }

    await auditModel.log({
      actorId: req.member.id,
      action: 'ADD_VIBHAG_HEAD',
      targetId: memberId,
      targetType: 'member',
      metadata: { vibhag_type: type },
    });

    const heads = await vibhagModel.listHeads(type);
    return res.status(201).json({ heads });
  } catch (err) {
    return next(err);
  }
}

// DELETE /api/vibhags/:type/heads/:memberId  (admin only)
async function removeHead(req, res, next) {
  try {
    const { type } = req.params;
    const memberId = parseInt(req.params.memberId, 10);

    const removed = await vibhagModel.removeHead(type, memberId);
    if (!removed) {
      return res.status(404).json({
        code: 'HEAD_NOT_FOUND',
        message: 'This member does not lead this vibhag.',
      });
    }

    await auditModel.log({
      actorId: req.member.id,
      action: 'REMOVE_VIBHAG_HEAD',
      targetId: memberId,
      targetType: 'member',
      metadata: { vibhag_type: type },
    });

    const heads = await vibhagModel.listHeads(type);
    return res.json({ heads });
  } catch (err) {
    return next(err);
  }
}

module.exports = {
  listVibhags,
  getVibhag,
  updateVibhag,
  addHead,
  removeHead,
};
