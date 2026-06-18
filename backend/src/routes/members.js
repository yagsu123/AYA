// src/routes/members.js
const express = require('express');
const { body } = require('express-validator');
const controller = require('../controllers/profileController');
const membersController = require('../controllers/membersController');
const { validate } = require('../middleware/validate');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

// Active member directory — used by assignment pickers.
router.get('/', requireAuth, membersController.directory);

router.patch(
  '/role',
  requireAuth,
  validate([
    body('role')
      .isIn(['president', 'secretary', 'member'])
      .withMessage("Role must be 'president', 'secretary' or 'member'."),
  ]),
  controller.requestRole
);

module.exports = router;
