// src/controllers/adsController.js
const sharp = require('sharp');
const adsModel = require('../models/adsModel');
const auditModel = require('../models/auditModel');
const { storeImage } = require('../utils/storage');

// GET /api/ads
async function list(req, res, next) {
  try {
    return res.json({ ads: await adsModel.list(), limit: adsModel.ADS_LIMIT });
  } catch (err) {
    return next(err);
  }
}

// POST /api/ads  (admin · multipart: image + title? + link_url?)
async function create(req, res, next) {
  try {
    if (!req.file) {
      return res.status(400).json({ code: 'VALIDATION_ERROR', message: 'Ad image is required.' });
    }
    if ((await adsModel.count()) >= adsModel.ADS_LIMIT) {
      return res.status(400).json({
        code: 'ADS_LIMIT_REACHED',
        message: `Maximum ${adsModel.ADS_LIMIT} advertisements allowed.`,
      });
    }

    const processed = await sharp(req.file.buffer)
      .rotate()
      .resize(1200, 675, { fit: 'inside', withoutEnlargement: true })
      .webp({ quality: 80 })
      .toBuffer();
    const { url } = await storeImage(processed, 'ads');

    const ad = await adsModel.create({
      title: req.body.title,
      imageUrl: url,
      linkUrl: req.body.link_url,
      createdBy: req.member.id,
    });

    await auditModel.log({
      actorId: req.member.id, action: 'ADD_AD', targetId: ad.id, targetType: 'ad',
    });
    return res.status(201).json(ad);
  } catch (err) {
    return next(err);
  }
}

// PUT /api/ads/:id  (admin)
async function update(req, res, next) {
  try {
    const ad = await adsModel.update(parseInt(req.params.id, 10), {
      title: req.body.title,
      linkUrl: req.body.link_url,
      sortOrder: req.body.sort_order,
    });
    if (!ad) return res.status(404).json({ code: 'AD_NOT_FOUND', message: 'Ad not found.' });
    await auditModel.log({
      actorId: req.member.id, action: 'UPDATE_AD', targetId: ad.id, targetType: 'ad',
    });
    return res.json(ad);
  } catch (err) {
    return next(err);
  }
}

// DELETE /api/ads/:id  (admin)
async function remove(req, res, next) {
  try {
    const ok = await adsModel.remove(parseInt(req.params.id, 10));
    if (!ok) return res.status(404).json({ code: 'AD_NOT_FOUND', message: 'Ad not found.' });
    await auditModel.log({
      actorId: req.member.id, action: 'DELETE_AD',
      targetId: parseInt(req.params.id, 10), targetType: 'ad',
    });
    return res.json({ success: true });
  } catch (err) {
    return next(err);
  }
}

module.exports = { list, create, update, remove };
