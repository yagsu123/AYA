// src/middleware/validate.js — runs express-validator chains, returns 400 on failure.
const { validationResult } = require('express-validator');

function validate(chains) {
  return [
    ...chains,
    (req, res, next) => {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          code: 'VALIDATION_ERROR',
          message: errors.array()[0].msg,
          errors: errors.array().map((e) => ({ field: e.path, message: e.msg })),
        });
      }
      return next();
    },
  ];
}

module.exports = { validate };
