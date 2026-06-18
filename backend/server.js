// server.js — AYA backend entry point.
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');

const env = require('./src/config/env');
const authRoutes = require('./src/routes/auth');
const adminRoutes = require('./src/routes/admin');
const profileRoutes = require('./src/routes/profile');
const memberRoutes = require('./src/routes/members');
const dashboardRoutes = require('./src/routes/dashboard');
const adsRoutes = require('./src/routes/ads');
const eventRoutes = require('./src/routes/events');
const vibhagRoutes = require('./src/routes/vibhags');
const galleryRoutes = require('./src/routes/gallery');
const aesRoutes = require('./src/routes/aes');
const { birthdaysRouter, anniversariesRouter } = require('./src/routes/occasions');
const path = require('path');
const { UPLOADS_ROOT } = require('./src/utils/storage');
const { auditLogger } = require('./src/middleware/audit');

const app = express();

app.set('trust proxy', 1);
app.use(helmet());
app.use(
  cors({
    origin: (origin, cb) => {
      // Allow non-browser clients (no Origin header) and whitelisted origins.
      if (!origin || env.allowedOrigins.includes(origin)) return cb(null, true);
      return cb(new Error('Not allowed by CORS'));
    },
  })
);
app.use(express.json({ limit: '1mb' }));
app.use(auditLogger);

app.get('/api/health', (req, res) => res.json({ status: 'ok' }));
app.use('/api/auth', authRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/members', memberRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/ads', adsRoutes);
app.use('/api/events', eventRoutes);
app.use('/api/vibhags', vibhagRoutes);
app.use('/api/gallery', galleryRoutes);
app.use('/api/aes', aesRoutes);
app.use('/api/birthdays', birthdaysRouter);
app.use('/api/anniversaries', anniversariesRouter);
// Local photo storage (used until Google Drive credentials are configured).
app.use('/uploads', express.static(UPLOADS_ROOT, { maxAge: '7d' }));

// 404
app.use((req, res) => {
  res.status(404).json({ code: 'NOT_FOUND', message: 'Route not found.' });
});

// Central error handler - never leaks internals.
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  if (err.name === 'MulterError') {
    const msg = err.code === 'LIMIT_FILE_SIZE'
      ? 'Photo must be smaller than 5MB.'
      : 'Only JPEG, PNG or WebP images are allowed.';
    return res.status(400).json({ code: 'INVALID_PHOTO', message: msg });
  }
  if (err.message === 'Not allowed by CORS') {
    return res.status(403).json({ code: 'CORS_FORBIDDEN', message: 'Origin not allowed.' });
  }
  console.error('Unhandled error:', env.nodeEnv === 'production' ? err.message : err);
  return res.status(500).json({ code: 'SERVER_ERROR', message: 'Something went wrong.' });
});

app.listen(env.port, () => {
  console.log(`AYA backend listening on port ${env.port} (${env.nodeEnv})`);
});

module.exports = app;
