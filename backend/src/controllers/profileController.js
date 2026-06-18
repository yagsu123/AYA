// src/controllers/profileController.js
const sharp = require('sharp');
const profileModel = require('../models/profileModel');
const auditModel = require('../models/auditModel');
const { calcCompletionPct } = require('../utils/completion');
const { storeMemberPhoto } = require('../utils/storage');

async function recalc(memberId) {
  const [profile, children] = await Promise.all([
    profileModel.getByMemberId(memberId),
    profileModel.getChildren(memberId),
  ]);
  const pct = calcCompletionPct(profile, children);
  await profileModel.setCompletionPct(memberId, pct);
  return pct;
}

// GET /api/profile/me
async function getMe(req, res, next) {
  try {
    const [profile, children] = await Promise.all([
      profileModel.getByMemberId(req.member.id),
      profileModel.getChildren(req.member.id),
    ]);
    return res.json({
      member: {
        id: req.member.id,
        mobile: req.member.mobile,
        role: req.member.role,
        role_status: req.member.role_status,
      },
      profile,
      children,
    });
  } catch (err) {
    return next(err);
  }
}

// PUT /api/profile/me  (partial update OK)
async function updateMe(req, res, next) {
  try {
    await profileModel.upsert(req.member.id, req.body || {});
    const pct = await recalc(req.member.id);
    const [profile, children] = await Promise.all([
      profileModel.getByMemberId(req.member.id),
      profileModel.getChildren(req.member.id),
    ]);
    await auditModel.log({
      actorId: req.member.id,
      action: 'UPDATE_PROFILE',
      targetId: req.member.id,
      targetType: 'member',
    });
    return res.json({ profile: { ...profile, profile_complete_pct: pct }, children });
  } catch (err) {
    return next(err);
  }
}

// POST /api/profile/photo  (multipart: photo; field: type = member|spouse|child)
async function uploadPhoto(req, res, next) {
  try {
    if (!req.file) {
      return res.status(400).json({ code: 'VALIDATION_ERROR', message: 'Photo file is required.' });
    }

    // Compress: max 800x800, webp q80.
    const processed = await sharp(req.file.buffer)
      .rotate() // respect EXIF orientation
      .resize(800, 800, { fit: 'inside', withoutEnlargement: true })
      .webp({ quality: 80 })
      .toBuffer();

    const { url, driveId } = await storeMemberPhoto(processed, req.member.id);

    const type = req.body.type || 'member';
    if (type === 'member') {
      await profileModel.upsert(req.member.id, { photo_url: url, photo_drive_id: driveId });
      await recalc(req.member.id);
    } else if (type === 'spouse') {
      await profileModel.upsert(req.member.id, { spouse_photo_url: url, spouse_photo_drive_id: driveId });
    }
    // type === 'child': caller attaches the URL to the child via children endpoints.

    return res.json({ url, driveId });
  } catch (err) {
    return next(err);
  }
}

// POST /api/profile/children
async function addChild(req, res, next) {
  try {
    const child = await profileModel.addChild(req.member.id, req.body);
    await recalc(req.member.id);
    return res.status(201).json(child);
  } catch (err) {
    return next(err);
  }
}

// PUT /api/profile/children/:childId
async function updateChild(req, res, next) {
  try {
    const child = await profileModel.updateChild(
      req.member.id, parseInt(req.params.childId, 10), req.body);
    if (!child) {
      return res.status(404).json({ code: 'CHILD_NOT_FOUND', message: 'Child not found.' });
    }
    return res.json(child);
  } catch (err) {
    return next(err);
  }
}

// DELETE /api/profile/children/:childId
async function deleteChild(req, res, next) {
  try {
    const ok = await profileModel.deleteChild(req.member.id, parseInt(req.params.childId, 10));
    if (!ok) {
      return res.status(404).json({ code: 'CHILD_NOT_FOUND', message: 'Child not found.' });
    }
    await recalc(req.member.id);
    return res.json({ success: true });
  } catch (err) {
    return next(err);
  }
}

// PATCH /api/members/role — member requests a role; admin must approve.
async function requestRole(req, res, next) {
  try {
    const { role } = req.body;
    const result = role === 'member'
      ? await profileModel.setRole(req.member.id, 'member', 'approved')
      : await profileModel.setRole(req.member.id, role, 'pending');

    await auditModel.log({
      actorId: req.member.id,
      action: 'REQUEST_ROLE',
      targetId: req.member.id,
      targetType: 'member',
      metadata: { role },
    });
    return res.json({ role: result.role, role_status: result.role_status });
  } catch (err) {
    return next(err);
  }
}

// PATCH /api/admin/members/:id/role/approve
async function approveRole(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    const { approve } = req.body;
    const result = approve
      ? await profileModel.setRole(id, (await require('../models/memberModel').findById(id)).role, 'approved')
      : await profileModel.setRole(id, 'member', 'approved');

    await auditModel.log({
      actorId: req.member.id,
      action: 'APPROVE_ROLE',
      targetId: id,
      targetType: 'member',
      metadata: { approve },
    });
    return res.json({ id, role: result.role, role_status: result.role_status });
  } catch (err) {
    return next(err);
  }
}

module.exports = {
  getMe, updateMe, uploadPhoto,
  addChild, updateChild, deleteChild,
  requestRole, approveRole,
};
