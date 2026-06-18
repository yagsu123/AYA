// scripts/migrate.js — runs all migrations/*.sql in order.
// Replaces {{ADMIN_PASSWORD_HASH}} with a fresh bcrypt hash of admin@123
// so no hash (and no plain password) ever lives in the repo.
require('dotenv').config();
const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');

async function run() {
  const pool = new Pool({ connectionString: process.env.DATABASE_URL });
  const dir = path.join(__dirname, '..', 'migrations');
  const files = fs.readdirSync(dir).filter((f) => f.endsWith('.sql')).sort();

  const adminHash = await bcrypt.hash('Jin@24', 12);

  for (const file of files) {
    let sql = fs.readFileSync(path.join(dir, file), 'utf8');
    sql = sql.replaceAll('{{ADMIN_PASSWORD_HASH}}', () => adminHash);
    console.log(`Running ${file}...`);
    await pool.query(sql);
  }

  console.log('Migrations complete.');
  await pool.end();
}

run().catch((err) => {
  console.error('Migration failed:', err.message);
  process.exit(1);
});
