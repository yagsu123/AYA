// src/routes/gallery.js — photo gallery (albums + photos).
// Any authenticated member may create albums and upload photos.
const express = require('express');
const multer = require('multer');
const { body, param } = require('express-validator');
const controller = require('../controllers/galleryController');
const { validate } = require('../middleware/validate');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();
router.use(requireAuth);

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const ok = ['image/jpeg', 'image/png', 'image/webp'].includes(file.mimetype);
    cb(ok ? null : new multer.MulterError('LIMIT_UNEXPECTED_FILE', 'image'), ok);
  },
});

router.get('/albums', controller.listAlbums);

router.post(
  '/albums',
  validate([
    body('title').trim().notEmpty().withMessage('Album title is required.')
      .isLength({ max: 150 }).withMessage('Title is too long.'),
    body('description').optional({ values: 'null' }).isString(),
    body('event_id').optional({ values: 'falsy' }).isInt(),
    body('year').optional({ values: 'falsy' }).isInt({ min: 2000, max: 2100 }),
  ]),
  controller.createAlbum
);

router.get(
  '/albums/:id',
  validate([param('id').isInt().withMessage('Invalid album id.')]),
  controller.getAlbum
);

router.delete(
  '/albums/:id',
  validate([param('id').isInt().withMessage('Invalid album id.')]),
  controller.deleteAlbum
);

router.post(
  '/albums/:id/photos',
  validate([param('id').isInt().withMessage('Invalid album id.')]),
  upload.single('image'),
  controller.uploadPhoto
);

router.delete(
  '/photos/:photoId',
  validate([param('photoId').isInt().withMessage('Invalid photo id.')]),
  controller.deletePhoto
);

module.exports = router;
