// src/routes/admin.js — all routes require JWT + president/secretary role.
const express = require('express');
const { body, param } = require('express-validator');
const controller = require('../controllers/adminController');
const profileController = require('../controllers/profileController');
const { validate } = require('../middleware/validate');
const { requireAuth } = require('../middleware/auth');
const { requireRole } = require('../middleware/roles');

const router = express.Router();

router.use(requireAuth, requireRole('president', 'secretary'));

router.post(
  '/members',
  validate([
    body('mobile')
      .trim()
      .notEmpty().withMessage('Mobile number is required.')
      .matches(/^[0-9]{10}$/).withMessage('Mobile number must be exactly 10 digits.'),
  ]),
  controller.addMember
);

router.get('/members', controller.listMembers);

router.patch(
  '/members/:id/status',
  validate([
    param('id').isInt().withMessage('Invalid member id.'),
    body('status')
      .isIn(['active', 'inactive']).withMessage("Status must be 'active' or 'inactive'."),
  ]),
  controller.updateStatus
);

router.patch(
  '/members/:id/role/approve',
  validate([
    param('id').isInt().withMessage('Invalid member id.'),
    body('approve').isBoolean().withMessage('approve must be true or false.'),
  ]),
  profileController.approveRole
);

router.delete(
  '/members/:id',
  validate([param('id').isInt().withMessage('Invalid member id.')]),
  controller.deleteMember
);

router.get('/stats', controller.getStats);

module.exports = router;
