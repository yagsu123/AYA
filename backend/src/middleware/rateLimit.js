// src/middleware/rateLimit.js — 10 login attempts per 15 minutes per IP.
const rateLimit = require('express-rate-limit');

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    code: 'TOO_MANY_ATTEMPTS',
    message: 'Too many login attempts. Please try again in 15 minutes.',
  },
});

module.exports = { loginLimiter };
