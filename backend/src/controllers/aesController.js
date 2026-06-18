// src/controllers/aesController.js — AES content (read for all, edit for admins).
const aesModel = require('../models/aesModel');
const auditModel = require('../models/auditModel');
const { isAdmin } = require('../middleware/vibhagAccess');

// GET /api/aes
async function getAes(req, res, next) {
  try {
    const content = await aesModel.getContent();
    return res.json({ content, is_admin: isAdmin(req.member) });
  } catch (err) {
    return next(err);
  }
}

// PUT /api/aes  (admin only — wired via requireRole)
async function updateAes(req, res, next) {
  try {
    const content = await aesModel.updateContent({
      whatIsAes: req.body.what_is_aes,
      history: req.body.history,
      objectives: req.body.objectives,
      donationContact: req.body.donation_contact,
      progressCurrent: req.body.progress_current,
      progressTarget: req.body.progress_target,
    });
    if (!content) {
      return res.status(404).json({ code: 'AES_NOT_FOUND', message: 'AES content not found.' });
    }
    await auditModel.log({
      actorId: req.member.id,
      action: 'UPDATE_AES',
      targetType: 'aes',
    });
    return res.json({ content });
  } catch (err) {
    return next(err);
  }
}

module.exports = { getAes, updateAes };
