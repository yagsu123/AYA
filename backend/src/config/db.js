// src/config/db.js — PostgreSQL pool. All queries go through query() and are
// parameterized at the call site; never interpolate values into SQL strings.
const { Pool } = require('pg');
const env = require('./env');

const pool = new Pool({ connectionString: env.databaseUrl });

pool.on('error', (err) => {
  console.error('Unexpected PG pool error', err.message);
});

module.exports = {
  query: (text, params) => pool.query(text, params),
  pool,
};
