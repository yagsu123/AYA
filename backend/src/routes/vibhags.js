// src/routes/vibhags.js — vibhag catalogue, heads and per-vibhag events.
// Listing/detail is open to any authenticated member. Editing a vibhag and
// appointing/removing heads is restricted to approved president/secretary.
const express = require('express');
const { body, param } = require('express-validator');
const controller = require('../controllers/vibhagsController');
const { validate } = require('../middleware/validate');
const { requireAuth } = require('../middleware/auth');
const { requireRole } = require('../middleware/roles');

const router = express.Router();
router.use(requireAuth);

const VIBHAG_TYPES = ['paryushan', 'snatra', 'sangeet', 'aangi', 'seva', 'jeev_daya'];
const typeParam = param('type')
  .isIn(VIBHAG_TYPES).withMessage('Unknown vibhag.');

router.get('/', controller.listVibhags);

router.get('/:type', validate([typeParam]), controller.getVibhag);

const adminOnly = requireRole('president', 'secretary');

router.put(
  '/:type',
  adminOnly,
  validate([
    typeParam,
    body('name').optional({ values: 'falsy' }).isLength({ max: 60 }),
    body('description').optional({ values: 'null' }).isString(),
    body('color').optional({ values: 'falsy' })
      .matches(/^#[0-9A-Fa-f]{6}$/).withMessage('Color must be a hex value like #2992D6.'),
    body('icon').optional({ values: 'falsy' }).isLength({ max: 40 }),
  ]),
  controller.updateVibhag
);

router.post(
  '/:type/heads',
  adminOnly,
  validate([
    typeParam,
    body('member_id').isInt().withMessage('A valid member is required.'),
  ]),
  controller.addHead
);

router.delete(
  '/:type/heads/:memberId',
  adminOnly,
  validate([
    typeParam,
    param('memberId').isInt().withMessage('Invalid member id.'),
  ]),
  controller.removeHead
);

module.exports = router;
