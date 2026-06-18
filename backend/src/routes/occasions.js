// src/routes/occasions.js
const express = require('express');
const controller = require('../controllers/occasionsController');
const { requireAuth } = require('../middleware/auth');

const birthdaysRouter = express.Router();
birthdaysRouter.get('/', requireAuth, controller.birthdays);

const anniversariesRouter = express.Router();
anniversariesRouter.get('/', requireAuth, controller.anniversaries);

module.exports = { birthdaysRouter, anniversariesRouter };
