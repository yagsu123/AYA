// src/routes/events.js — events + member-entered labarthi records.
// All routes require auth; any authenticated member may manage events/labarthis.
const express = require('express');
const { body, param } = require('express-validator');
const controller = require('../controllers/eventsController');
const { validate } = require('../middleware/validate');
const { requireAuth } = require('../middleware/auth');
const { requireRole } = require('../middleware/roles');

const router = express.Router();
router.use(requireAuth);

const TIME_RE = /^\d{2}:\d{2}(:\d{2})?$/;

// Name, date and start time are required. end_date (multi-day) and end_time are
// optional; end_date, when present, must be on or after the start date.
const eventBody = (isCreate) => [
  body('vibhag_type')
    .if(() => isCreate)
    .trim().notEmpty().withMessage('Vibhag is required.'),
  body('name')
    .trim().notEmpty().withMessage('Event name is required.')
    .isLength({ max: 150 }).withMessage('Event name is too long.'),
  body('date')
    .isISO8601().withMessage('A valid event date is required.'),
  body('time')
    .trim().notEmpty().withMessage('Start time is required.')
    .matches(TIME_RE).withMessage('Start time must be in HH:MM format.'),
  body('end_time')
    .optional({ values: 'falsy' })
    .matches(TIME_RE).withMessage('End time must be in HH:MM format.'),
  body('end_date')
    .optional({ values: 'falsy' })
    .isISO8601().withMessage('Invalid end date.')
    .custom((value, { req }) =>
      !req.body.date || new Date(value) >= new Date(req.body.date))
    .withMessage('End date must be on or after the start date.'),
  body('venue').optional({ values: 'null' }).isLength({ max: 200 }),
  body('description').optional({ values: 'null' }).isString(),
];

router.get('/', controller.listEvents);

router.post('/', validate(eventBody(true)), controller.createEvent);

router.get(
  '/:id',
  validate([param('id').isInt().withMessage('Invalid event id.')]),
  controller.getEvent
);

router.put(
  '/:id',
  validate([param('id').isInt().withMessage('Invalid event id.'), ...eventBody(false)]),
  controller.updateEvent
);

router.delete(
  '/:id',
  validate([param('id').isInt().withMessage('Invalid event id.')]),
  controller.deleteEvent
);

router.post(
  '/:id/labarthis',
  validate([
    param('id').isInt().withMessage('Invalid event id.'),
    body('name').trim().notEmpty().withMessage('Labarthi name is required.')
      .isLength({ max: 150 }).withMessage('Name is too long.'),
    body('amount')
      .optional({ values: 'falsy' })
      .isFloat({ min: 0 }).withMessage('Amount must be a positive number.'),
    body('note').optional({ values: 'null' }).isLength({ max: 500 }),
  ]),
  controller.addLabarthi
);

router.delete(
  '/:id/labarthis/:labarthiId',
  validate([
    param('id').isInt().withMessage('Invalid event id.'),
    param('labarthiId').isInt().withMessage('Invalid labarthi id.'),
  ]),
  controller.removeLabarthi
);

// Assigned members — editable by members while open, admins anytime.
router.put(
  '/:id/assignments',
  validate([
    param('id').isInt().withMessage('Invalid event id.'),
    body('member_ids').isArray().withMessage('member_ids must be an array.'),
    body('member_ids.*').isInt().withMessage('member_ids must be integers.'),
  ]),
  controller.setAssignments
);

// Lock / unlock the member list — admins only.
router.patch(
  '/:id/members-lock',
  requireRole('president', 'secretary'),
  validate([
    param('id').isInt().withMessage('Invalid event id.'),
    body('locked').isBoolean().withMessage('locked must be true or false.'),
  ]),
  controller.setMembersLock
);

module.exports = router;
