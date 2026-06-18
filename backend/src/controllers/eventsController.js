// src/controllers/eventsController.js — Phase 6 events + labarthi records.
const eventModel = require('../models/eventModel');
const vibhagModel = require('../models/vibhagModel');
const auditModel = require('../models/auditModel');
const { isAdmin } = require('../middleware/vibhagAccess');

const VALID_SCOPES = ['upcoming', 'past', 'all'];

// Any authenticated member may create/edit/delete events and add labarthi
// records. Contribution amounts are returned only to admins (authorised users).
function notFound(res, message = 'Event not found.') {
  return res.status(404).json({ code: 'EVENT_NOT_FOUND', message });
}

// GET /api/events?vibhag_type=&scope=upcoming|past|all
async function listEvents(req, res, next) {
  try {
    const scope = VALID_SCOPES.includes(req.query.scope) ? req.query.scope : 'upcoming';
    const vibhagType = req.query.vibhag_type || null;
    const items = await eventModel.list({ vibhagType, scope });
    return res.json({ scope, vibhag_type: vibhagType, items });
  } catch (err) {
    return next(err);
  }
}

// GET /api/events/:id  → event + labarthi records (amounts only for admins).
async function getEvent(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    const event = await eventModel.findById(id);
    if (!event) return notFound(res);

    const admin = isAdmin(req.member);
    const [rows, assignments] = await Promise.all([
      eventModel.listLabarthis(id),
      eventModel.listAssignments(id),
    ]);
    const labarthis = rows.map((l) => ({
      id: l.id,
      name: l.name,
      note: l.note,
      added_by_name: l.added_by_name,
      // Financial detail is exposed only to authorised users.
      amount: admin ? l.amount : undefined,
    }));

    return res.json({
      event,
      labarthis,
      assignments,
      can_manage: true,
      can_view_amounts: admin,
      is_admin: admin,
      // Members may edit the list while open; once locked only admins may.
      can_edit_members: !event.members_locked || admin,
    });
  } catch (err) {
    return next(err);
  }
}

// POST /api/events  (any authenticated member)
async function createEvent(req, res, next) {
  try {
    const { vibhag_type: vibhagType } = req.body;

    const vibhag = await vibhagModel.findByType(vibhagType);
    if (!vibhag) {
      return res.status(400).json({ code: 'INVALID_VIBHAG', message: 'Unknown vibhag.' });
    }

    const event = await eventModel.create({
      vibhagType,
      name: req.body.name,
      date: req.body.date,
      endDate: req.body.end_date,
      time: req.body.time,
      endTime: req.body.end_time,
      venue: req.body.venue,
      description: req.body.description,
      createdBy: req.member.id,
    });

    await auditModel.log({
      actorId: req.member.id,
      action: 'CREATE_EVENT',
      targetId: event.id,
      targetType: 'event',
      metadata: { vibhag_type: vibhagType, name: event.name },
    });

    return res.status(201).json({ event });
  } catch (err) {
    return next(err);
  }
}

// PUT /api/events/:id
async function updateEvent(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    const existing = await eventModel.findById(id);
    if (!existing) return notFound(res);

    const event = await eventModel.update(
      id,
      {
        name: req.body.name,
        date: req.body.date,
        endDate: req.body.end_date,
        time: req.body.time,
        endTime: req.body.end_time,
        venue: req.body.venue,
        description: req.body.description,
      },
      req.member.id
    );

    await auditModel.log({
      actorId: req.member.id,
      action: 'UPDATE_EVENT',
      targetId: id,
      targetType: 'event',
      metadata: { name: event.name },
    });

    return res.json({ event });
  } catch (err) {
    return next(err);
  }
}

// DELETE /api/events/:id
async function deleteEvent(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    const existing = await eventModel.findById(id);
    if (!existing) return notFound(res);

    await eventModel.remove(id);
    await auditModel.log({
      actorId: req.member.id,
      action: 'DELETE_EVENT',
      targetId: id,
      targetType: 'event',
      metadata: { name: existing.name },
    });

    return res.json({ id, deleted: true });
  } catch (err) {
    return next(err);
  }
}

// POST /api/events/:id/labarthis  (a member records a beneficiary + amount)
async function addLabarthi(req, res, next) {
  try {
    const eventId = parseInt(req.params.id, 10);
    const event = await eventModel.findById(eventId);
    if (!event) return notFound(res);

    const created = await eventModel.addLabarthi({
      eventId,
      name: req.body.name,
      amount: req.body.amount,
      note: req.body.note,
      addedBy: req.member.id,
    });

    await auditModel.log({
      actorId: req.member.id,
      action: 'ADD_LABARTHI',
      targetId: eventId,
      targetType: 'event',
      metadata: { labarthi_id: created.id },
    });

    return res.status(201).json({ id: created.id });
  } catch (err) {
    return next(err);
  }
}

// DELETE /api/events/:id/labarthis/:labarthiId
async function removeLabarthi(req, res, next) {
  try {
    const eventId = parseInt(req.params.id, 10);
    const labarthiId = parseInt(req.params.labarthiId, 10);

    const labarthi = await eventModel.findLabarthiById(labarthiId);
    if (!labarthi || labarthi.event_id !== eventId) {
      return res.status(404).json({
        code: 'LABARTHI_NOT_FOUND',
        message: 'Labarthi record not found.',
      });
    }

    await eventModel.removeLabarthi(labarthiId);
    await auditModel.log({
      actorId: req.member.id,
      action: 'REMOVE_LABARTHI',
      targetId: eventId,
      targetType: 'event',
      metadata: { labarthi_id: labarthiId },
    });

    return res.json({ id: labarthiId, removed: true });
  } catch (err) {
    return next(err);
  }
}

// PUT /api/events/:id/assignments  { member_ids: [int] }
// Editable by any member while open; once locked, only admins may change it.
async function setAssignments(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    const event = await eventModel.findById(id);
    if (!event) return notFound(res);

    if (event.members_locked && !isAdmin(req.member)) {
      return res.status(423).json({
        code: 'MEMBERS_LOCKED',
        message: 'The member list is locked. Ask an admin to unlock it.',
      });
    }

    const memberIds = Array.isArray(req.body.member_ids)
      ? [...new Set(req.body.member_ids.map(Number).filter(Number.isInteger))]
      : [];
    const assignments = await eventModel.setAssignments(id, memberIds, req.member.id);

    await auditModel.log({
      actorId: req.member.id,
      action: 'SET_EVENT_MEMBERS',
      targetId: id,
      targetType: 'event',
      metadata: { count: memberIds.length, while_locked: event.members_locked },
    });

    return res.json({ assignments });
  } catch (err) {
    return next(err);
  }
}

// PATCH /api/events/:id/members-lock  { locked: bool }  (admin only, via router)
async function setMembersLock(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    const event = await eventModel.findById(id);
    if (!event) return notFound(res);

    const locked = req.body.locked === true;
    const updated = await eventModel.lockMembers(id, locked, req.member.id);

    await auditModel.log({
      actorId: req.member.id,
      action: locked ? 'LOCK_EVENT_MEMBERS' : 'UNLOCK_EVENT_MEMBERS',
      targetId: id,
      targetType: 'event',
    });

    return res.json({ event: updated });
  } catch (err) {
    return next(err);
  }
}

module.exports = {
  listEvents,
  getEvent,
  createEvent,
  updateEvent,
  deleteEvent,
  addLabarthi,
  removeLabarthi,
  setAssignments,
  setMembersLock,
};
