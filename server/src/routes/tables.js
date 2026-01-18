const express = require('express');
const router = express.Router();
const db = require('../db');
const { auth } = require('../middleware/auth');

// Locations list
router.get('/locations', async (req, res) => {
  try {
    const { rows } = await db.query('SELECT id, code, name, address FROM locations ORDER BY id');
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// Floors for a location
router.get('/floors', async (req, res) => {
  const { location_id } = req.query;
  try {
    const { rows } = await db.query('SELECT id, location_id, name, level FROM floors WHERE location_id=$1 ORDER BY level', [location_id]);
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// Tables for a location & floor
router.get('/', async (req, res) => {
  const { location_id, floor_id } = req.query;
  try {
    const { rows } = await db.query(
      `SELECT t.id, t.location_id, t.floor_id, t.table_number, t.qr_code, t.status
       FROM cafe_tables t
       WHERE ($1::int IS NULL OR t.location_id=$1) AND ($2::int IS NULL OR t.floor_id=$2)
       ORDER BY t.table_number`, [location_id || null, floor_id || null]
    );
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// Update table status
router.put('/:id/status', auth(), async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  try {
    await db.query('UPDATE cafe_tables SET status=$1 WHERE id=$2', [status, id]);
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
