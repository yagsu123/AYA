// scripts/hash-password.js — utility: npm run hash -- <password>
const bcrypt = require('bcryptjs');
const pwd = process.argv[2];
if (!pwd) {
  console.error('Usage: npm run hash -- <password>');
  process.exit(1);
}
bcrypt.hash(pwd, 12).then((h) => console.log(h));
