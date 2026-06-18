// src/routes/auth.js
const express = require('express');
const { body } = require('express-validator');
const controller = require('../controllers/authController');
const { validate } = require('../middleware/validate');
const { requireAuth } = require('../middleware/auth');
const { loginLimiter } = require('../middleware/rateLimit');

const router = express.Router();

const loginRules = validate([
  body('mobile')
    .trim()
    .notEmpty().withMessage('Mobile number is required.')
    .matches(/^[0-9]{10}$/).withMessage('Mobile number must be exactly 10 digits.'),
  body('password')
    .notEmpty().withMessage('Password is required.'),
]);

router.post('/login', loginLimiter, loginRules, controller.login);
router.post('/refresh', controller.refresh);
router.post('/logout', requireAuth, controller.logout);
router.get('/me', requireAuth, controller.me);

module.exports = router;
