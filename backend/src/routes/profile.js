// src/routes/profile.js — all routes JWT-protected.
const express = require('express');
const multer = require('multer');
const { body, param } = require('express-validator');
const controller = require('../controllers/profileController');
const { validate } = require('../middleware/validate');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

// Photo upload: memory storage, images only, max 5MB.
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const ok = ['image/jpeg', 'image/png', 'image/webp'].includes(file.mimetype);
    cb(ok ? null : new multer.MulterError('LIMIT_UNEXPECTED_FILE', 'photo'), ok);
  },
});

router.use(requireAuth);

router.get('/me', controller.getMe);
router.put('/me', controller.updateMe);

router.post('/photo', upload.single('photo'), controller.uploadPhoto);

router.post(
  '/children',
  validate([body('name').trim().notEmpty().withMessage('Child name is required.')]),
  controller.addChild
);
router.put(
  '/children/:childId',
  validate([param('childId').isInt().withMessage('Invalid child id.')]),
  controller.updateChild
);
router.delete(
  '/children/:childId',
  validate([param('childId').isInt().withMessage('Invalid child id.')]),
  controller.deleteChild
);

module.exports = router;
