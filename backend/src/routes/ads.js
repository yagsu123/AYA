// src/routes/ads.js
const express = require('express');
const multer = require('multer');
const { param } = require('express-validator');
const controller = require('../controllers/adsController');
const { validate } = require('../middleware/validate');
const { requireAuth } = require('../middleware/auth');
const { requireRole } = require('../middleware/roles');

const router = express.Router();

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const ok = ['image/jpeg', 'image/png', 'image/webp'].includes(file.mimetype);
    cb(ok ? null : new multer.MulterError('LIMIT_UNEXPECTED_FILE', 'image'), ok);
  },
});

router.get('/', requireAuth, controller.list);
router.post('/', requireAuth, requireRole('president', 'secretary'),
  upload.single('image'), controller.create);
router.put('/:id', requireAuth, requireRole('president', 'secretary'),
  validate([param('id').isInt()]), controller.update);
router.delete('/:id', requireAuth, requireRole('president', 'secretary'),
  validate([param('id').isInt()]), controller.remove);

module.exports = router;
