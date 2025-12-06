const express = require('express');
const router = express.Router();
const db = require('../db');
const { auth } = require('../middleware/auth');

// ===== CATEGORY ROUTES (must be before /:id routes) =====

// Get all categories
router.get('/categories', async (req, res) => {
  try {
    const { rows } = await db.query('SELECT * FROM categories ORDER BY name');
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// Create category (admin)
router.post('/categories', auth('admin'), async (req, res) => {
  const { name } = req.body;
  try {
    const { rows } = await db.query(
      'INSERT INTO categories (name) VALUES ($1) RETURNING *',
      [name]
    );
    res.status(201).json(rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// Update category (admin)
router.put('/categories/:id', auth('admin'), async (req, res) => {
  const id = req.params.id;
  const { name } = req.body;
  try {
    const { rows } = await db.query(
      'UPDATE categories SET name=$1 WHERE id=$2 RETURNING *',
      [name, id]
    );
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Category not found' });
    }
    res.json(rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// Delete category (admin)
router.delete('/categories/:id', auth('admin'), async (req, res) => {
  const id = req.params.id;
  try {
    // Check if category has items
    const { rows: itemRows } = await db.query('SELECT COUNT(*) as count FROM items WHERE category_id=$1', [id]);
    if (parseInt(itemRows[0].count) > 0) {
      return res.status(400).json({ error: 'Cannot delete category with existing items' });
    }
    
    const { rows } = await db.query('DELETE FROM categories WHERE id=$1 RETURNING *', [id]);
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Category not found' });
    }
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// ===== ITEM ROUTES =====

// Get all menu items (with category)
router.get('/', async (req, res) => {
  try {
    const { search } = req.query;
    let query = `
      SELECT i.id, i.name, i.price, i.available, i.image_url, c.id as category_id, c.name as category_name
      FROM items i JOIN categories c ON i.category_id=c.id
    `;
    
    if (search) {
      query += ` WHERE i.name ILIKE $1 OR c.name ILIKE $1`;
      query += ` ORDER BY c.name, i.name`;
      const { rows } = await db.query(query, [`%${search}%`]);
      res.json(rows);
    } else {
      query += ` ORDER BY c.name, i.name`;
      const { rows } = await db.query(query);
      res.json(rows);
    }
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// Create item (admin)
router.post('/', auth('admin'), async (req, res) => {
  const { name, price, category_id, available=true, image_url=null } = req.body;
  try {
    const { rows } = await db.query(
      'INSERT INTO items (name, price, category_id, available, image_url) VALUES ($1,$2,$3,$4,$5) RETURNING *',
      [name, price, category_id, available, image_url]
    );
    res.status(201).json(rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// Update item (admin)
router.put('/:id', auth('admin'), async (req, res) => {
  const id = req.params.id;
  const { name, price, category_id, available, image_url } = req.body;
  try {
    const { rows } = await db.query(
      'UPDATE items SET name=$1, price=$2, category_id=$3, available=$4, image_url=$5 WHERE id=$6 RETURNING *',
      [name, price, category_id, available, image_url, id]
    );
    res.json(rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// Delete item (admin)
router.delete('/:id', auth('admin'), async (req, res) => {
  const id = req.params.id;
  try {
    await db.query('DELETE FROM items WHERE id=$1', [id]);
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
