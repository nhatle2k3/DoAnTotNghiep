const bcrypt = require('bcryptjs');
const dotenv = require('dotenv');
dotenv.config();

const db = require('../src/db');

async function run() {
  try {
    const adminEmail = 'admin@trinhcafe.vn';
    const password = 'admin123';

    const hash = await bcrypt.hash(password, 10);

    await db.query(
      `
      INSERT INTO users (full_name, email, password_hash, role)
      VALUES ($1, $2, $3, $4)
      ON CONFLICT (email)
      DO UPDATE SET
        full_name = EXCLUDED.full_name,
        password_hash = EXCLUDED.password_hash,
        role = EXCLUDED.role
      `,
      ['Administrator', adminEmail, hash, 'admin']
    );

    console.log('✅ Admin user upserted successfully.');
    console.log('Email:', adminEmail);
    console.log('Password:', password);
    process.exit(0);
  } catch (err) {
    console.error('❌ Failed to upsert admin user:', err);
    process.exit(1);
  }
}

run();


