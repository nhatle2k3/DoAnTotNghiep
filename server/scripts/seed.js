// Create admin, floors, tables; hash pwd; generate QR code images
const fs = require('fs');
const path = require('path');
const bcrypt = require('bcryptjs');
const QRCode = require('qrcode');
const db = require('../src/db');
const dotenv = require('dotenv');
dotenv.config();

const QR_DIR = process.env.QR_OUTPUT_DIR || 'qr_codes';
if (!fs.existsSync(QR_DIR)) {
  fs.mkdirSync(QR_DIR, { recursive: true });
} else {
  // Clean up old QR code files before generating new ones
  console.log('🧹 Cleaning up old QR code files...');
  const files = fs.readdirSync(QR_DIR);
  let deletedCount = 0;
  files.forEach(file => {
    // Only delete PNG files (QR codes), keep directories and other files
    if (file.endsWith('.png')) {
      const filePath = path.join(QR_DIR, file);
      try {
        fs.unlinkSync(filePath);
        deletedCount++;
      } catch (error) {
        console.warn(`⚠️  Could not delete old file ${file}:`, error.message);
      }
    }
  });
  if (deletedCount > 0) {
    console.log(`🗑️  Deleted ${deletedCount} old QR code file(s)`);
  }
}

async function run() {
  try {
    // Load schema & seed basics
    const schema = fs.readFileSync(path.join(__dirname, '..', 'sql', 'schema.sql'), 'utf8');
    await db.query(schema);
    const seed = fs.readFileSync(path.join(__dirname, '..', 'sql', 'seed.sql'), 'utf8');
    await db.query(seed);

    // Upsert admin user
    const adminEmail = 'admin@trinhcafe.vn';
    const hash = await bcrypt.hash('admin123', 10);
    await db.query(`
      INSERT INTO users (full_name, email, password_hash, role)
      VALUES ($1,$2,$3,$4)
      ON CONFLICT (email) DO UPDATE SET full_name=EXCLUDED.full_name, password_hash=EXCLUDED.password_hash, role=EXCLUDED.role
    `, ['Administrator', adminEmail, hash, 'admin']);

    // Create tables for each location: 30 tables per location
    // Create a default floor for each location (required by schema, but not used in logic)
    const locs = await db.query('SELECT id, code FROM locations ORDER BY id');
    for (const loc of locs.rows) {
      // Check if floor exists, if not create one
      let floorResult = await db.query(
        'SELECT id FROM floors WHERE location_id=$1 LIMIT 1',
        [loc.id]
      );
      
      let floorId;
      if (floorResult.rows.length === 0) {
        // Create a default floor (required by schema)
        floorResult = await db.query(
          'INSERT INTO floors (location_id, name, level) VALUES ($1,$2,$3) RETURNING id',
          [loc.id, 'Tầng 1', 1]
        );
        floorId = floorResult.rows[0].id;
      } else {
        floorId = floorResult.rows[0].id;
      }
      
      // Create 30 tables for this location
      const host = process.env.QR_HOST || process.env.API_HOST || 'http://localhost:4000';
      for (let tableNum = 1; tableNum <= 30; tableNum++) {
        // Generate QR payload without floor
        const payload = `${host.replace(/\/$/, '')}/order-simple.html?location=${loc.code}&table=${tableNum}`;
        const fileName = `${loc.code}-T${tableNum}.png`;
        const filePath = path.join(QR_DIR, fileName);
        await QRCode.toFile(filePath, payload, { width: 300 });
        await db.query(
          'INSERT INTO cafe_tables (location_id, floor_id, table_number, qr_code, status) VALUES ($1,$2,$3,$4,$5)',
          [loc.id, floorId, tableNum, `/qr/${fileName}`, 'available']
        );
      }
    }

    console.log('Seed completed.');
    process.exit(0);
  } catch (e) {
    console.error('Seed error:', e);
    process.exit(1);
  }
}
run();
