// Script to generate printable QR code labels for tables
const fs = require('fs');
const path = require('path');
const QRCode = require('qrcode');
const db = require('../src/db');
const dotenv = require('dotenv');
dotenv.config();

const QR_DIR = process.env.QR_OUTPUT_DIR || 'qr_codes';
const PRINT_DIR = path.join(QR_DIR, 'printable');

async function generatePrintableLabels() {
  try {
    console.log('🖨️ Generating printable QR code labels...');
    
    // Create printable directory
    if (!fs.existsSync(PRINT_DIR)) {
      fs.mkdirSync(PRINT_DIR, { recursive: true });
      console.log(`📁 Created printable directory: ${PRINT_DIR}`);
    }
    
    // Get all tables with location info
    const { rows: tables } = await db.query(`
      SELECT t.id, t.location_id, t.floor_id, t.table_number, l.code, l.name
      FROM cafe_tables t
      JOIN locations l ON t.location_id = l.id
      ORDER BY t.location_id, t.table_number
    `);
    
    console.log(`📊 Found ${tables.length} tables to process`);
    
    // Group tables by location
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
    
    // Generate HTML for printing
    let htmlContent = generatePrintHTML(tablesByLocation);
    
    // Save HTML file
    const htmlFile = path.join(PRINT_DIR, 'qr-labels.html');
    fs.writeFileSync(htmlFile, htmlContent);
    
    console.log(`\n🎉 Printable labels generated!`);
    console.log(`📄 HTML file: ${htmlFile}`);
    console.log(`🌐 Open in browser: file://${htmlFile}`);
    console.log(`\n📋 Instructions:`);
    console.log(`   1. Open the HTML file in your browser`);
    console.log(`   2. Press Ctrl+P (or Cmd+P on Mac) to print`);
    console.log(`   3. Select "More settings" → "Options" → "Background graphics"`);
    console.log(`   4. Choose appropriate paper size (A4 recommended)`);
    console.log(`   5. Print and cut along the dotted lines`);
    
  } catch (error) {
    console.error('💥 Error generating printable labels:', error);
    process.exit(1);
  }
}

function generatePrintHTML(tablesByLocation) {
  return `<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>QR Code Labels - Trình Café</title>
    <style>
        @page {
            margin: 0.5cm;
            size: A4;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background: white;
        }
        
        .label {
            width: 8cm;
            height: 6cm;
            border: 2px dashed #ccc;
            margin: 0.2cm;
            padding: 0.3cm;
            display: inline-block;
            vertical-align: top;
            page-break-inside: avoid;
            box-sizing: border-box;
        }
        
        .label-header {
            text-align: center;
            margin-bottom: 0.2cm;
        }
        
        .cafe-name {
            font-size: 14px;
            font-weight: bold;
            color: #f59e0b;
            margin-bottom: 0.1cm;
        }
        
        .location-name {
            font-size: 12px;
            color: #666;
            margin-bottom: 0.1cm;
        }
        
        .table-info {
            font-size: 16px;
            font-weight: bold;
            color: #333;
        }
        
        .qr-container {
            text-align: center;
            margin: 0.2cm 0;
        }
        
        .qr-code {
            width: 3cm;
            height: 3cm;
            border: 1px solid #ddd;
        }
        
        .instructions {
            font-size: 10px;
            color: #666;
            text-align: center;
            margin-top: 0.1cm;
        }
        
        .page-break {
            page-break-before: always;
        }
        
        @media print {
            .label {
                border: 2px dashed #ccc !important;
            }
        }
    </style>
</head>
<body>
    ${Object.values(tablesByLocation).map((locationData, locationIndex) => `
        ${locationData.tables.map((table, tableIndex) => `
            <div class="label">
                <div class="label-header">
                    <div class="cafe-name">☕ TRÌNH CAFÉ</div>
                    <div class="location-name">${locationData.location.name}</div>
                    <div class="table-info">Bàn ${table.table_number}</div>
                </div>
                
                <div class="qr-container">
                    <img src="../${locationData.location.code}-T${table.table_number}.png" 
                         alt="QR Code" 
                         class="qr-code">
                </div>
                
                <div class="instructions">
                    Quét mã để đặt món<br>
                    Scan to order
                </div>
            </div>
            
            ${(tableIndex + 1) % 6 === 0 ? '<div class="page-break"></div>' : ''}
        `).join('')}
        
        ${locationIndex < Object.keys(tablesByLocation).length - 1 ? '<div class="page-break"></div>' : ''}
    `).join('')}
</body>
</html>`;
}

// Run if called directly
if (require.main === module) {
  generatePrintableLabels()
    .then(() => {
      console.log('\n✨ Script completed successfully!');
      process.exit(0);
    })
    .catch(error => {
      console.error('\n💥 Script failed:', error);
      process.exit(1);
    });
}

module.exports = { generatePrintableLabels };
