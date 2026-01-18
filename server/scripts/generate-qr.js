// Script to regenerate QR codes for all tables
const fs = require('fs');
const path = require('path');
const QRCode = require('qrcode');
const db = require('../src/db');
const dotenv = require('dotenv');
dotenv.config();

const QR_DIR = process.env.QR_OUTPUT_DIR || 'qr_codes';

async function generateQRForTable(table, location) {
  // Create QR payload - prefer QR_HOST env var (e.g. http://192.168.1.42:4000)
  const host = process.env.QR_HOST || process.env.API_HOST || 'http://localhost:4000';
  const payload = `${host.replace(/\/$/, '')}/order-simple.html?location=${location.code}&table=${table.table_number}`;
  
  const fileName = `${location.code}-T${table.table_number}.png`;
  const filePath = path.join(QR_DIR, fileName);
  
  try {
    // Generate QR code with better options
    await QRCode.toFile(filePath, payload, {
      width: 300,
      margin: 2,
      color: {
        dark: '#000000',
        light: '#FFFFFF'
      },
      errorCorrectionLevel: 'M'
    });
    
    // Update database with QR code path
    await db.query(
      'UPDATE cafe_tables SET qr_code = $1 WHERE id = $2',
      [`/qr/${fileName}`, table.id]
    );
    
    console.log(`✅ Generated QR for ${location.name} - Table ${table.table_number}`);
    console.log(`   ↪ URL: ${payload}`);
    return true;
  } catch (error) {
    console.error(`❌ Error generating QR for table ${table.id}:`, error.message);
    return false;
  }
}

async function regenerateAllQRCodes() {
  try {
    console.log('🔄 Starting QR code regeneration...');
    
    // Ensure QR directory exists
    if (!fs.existsSync(QR_DIR)) {
      fs.mkdirSync(QR_DIR, { recursive: true });
      console.log(`📁 Created QR directory: ${QR_DIR}`);
    } else {
      // Clean up old QR code files before generating new ones
      console.log('🧹 Cleaning up old QR code files...');
      const files = fs.readdirSync(QR_DIR);
      let deletedCount = 0;
      files.forEach(file => {
        // Only delete PNG files (QR codes), keep directories and other files like manifest.json
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
    
    // Get all tables with location info
    const { rows: tables } = await db.query(`
      SELECT t.id, t.location_id, t.floor_id, t.table_number, l.code, l.name
      FROM cafe_tables t
      JOIN locations l ON t.location_id = l.id
      ORDER BY t.location_id, t.table_number
    `);
    
    console.log(`📊 Found ${tables.length} tables to process`);
    
    let successCount = 0;
    let errorCount = 0;
    const manifest = [];
    
    // Group tables by location for better organization
    const tablesByLocation = {};
    tables.forEach(table => {
      if (!tablesByLocation[table.location_id]) {
        tablesByLocation[table.location_id] = {
          location: { code: table.code, name: table.name },
          tables: []
        };
      }
      tablesByLocation[table.location_id].tables.push(table);
    });
    
    // Process each location
    for (const [locationId, data] of Object.entries(tablesByLocation)) {
      console.log(`\n🏢 Processing ${data.location.name} (${data.location.code})`);
      
      for (const table of data.tables) {
        // Create QR payload - mirror logic in generateQRForTable for manifest
        const host = process.env.QR_HOST || process.env.API_HOST || 'http://localhost:4000';
        const payload = `${host.replace(/\/$/, '')}/order-simple.html?location=${data.location.code}&table=${table.table_number}`;

        const success = await generateQRForTable(table, data.location);
        if (success) {
          successCount++;
          manifest.push({
            locationCode: data.location.code,
            locationName: data.location.name,
            tableNumber: table.table_number,
            url: payload
          });
        } else {
          errorCount++;
        }
        
        // Small delay to avoid overwhelming the system
        await new Promise(resolve => setTimeout(resolve, 100));
      }
    }
    
    console.log(`\n🎉 QR Code regeneration completed!`);
    console.log(`✅ Successfully generated: ${successCount} QR codes`);
    console.log(`❌ Errors: ${errorCount} QR codes`);
    console.log(`📁 QR codes saved in: ${QR_DIR}`);

    // Write manifest for easy verification
    const manifestPath = path.join(QR_DIR, 'manifest.json');
    fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2));
    console.log(`📝 Manifest written: ${manifestPath}`);
    if (manifest.length > 0) {
      console.log('🔎 Sample URLs:');
      manifest.slice(0, 5).forEach(m => console.log(`   - ${m.url}`));
    }
    
    // List some example files
    const files = fs.readdirSync(QR_DIR).filter(f => f.endsWith('.png')).slice(0, 5);
    if (files.length > 0) {
      console.log(`\n📋 Example QR files:`);
      files.forEach(file => console.log(`   - ${file}`));
    }
    
  } catch (error) {
    console.error('💥 Fatal error during QR generation:', error);
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  regenerateAllQRCodes()
    .then(() => {
      console.log('\n✨ Script completed successfully!');
      process.exit(0);
    })
    .catch(error => {
      console.error('\n💥 Script failed:', error);
      process.exit(1);
    });
}

module.exports = { generateQRForTable, regenerateAllQRCodes };
