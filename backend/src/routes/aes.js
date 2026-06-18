// src/routes/aes.js — AES content. Read: any member. Edit: admins only.
const express = require('express');
const { body } = require('express-validator');
const controller = require('../controllers/aesController');
const { validate } = require('../middleware/validate');
const { requireAuth } = require('../middleware/auth');
const { requireRole } = require('../middleware/roles');

const router = express.Router();
router.use(requireAuth);

router.get('/', controller.getAes);

router.put(
  '/',
  requireRole('president', 'secretary'),
  validate([
    body('what_is_aes').optional({ values: 'null' }).isString(),
    body('history').optional({ values: 'null' }).isString(),
    body('objectives').optional({ values: 'null' }).isString(),
    body('donation_contact').optional({ values: 'falsy' })
      .matches(/^[0-9]{10}$/).withMessage('Donation contact must be 10 digits.'),
    body('progress_current').optional({ values: 'null' }).isFloat({ min: 0 }),
    body('progress_target').optional({ values: 'null' }).isFloat({ min: 0 }),
  ]),
  controller.updateAes
);

module.exports = router;
