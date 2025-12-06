const express = require('express');
const router = express.Router();
const db = require('../db');
const { auth } = require('../middleware/auth');

router.get('/sales-by-day', auth('admin'), async (req, res) => {
  try {
    const { rows } = await db.query(`
      SELECT DATE(p.created_at) as day, SUM(p.amount) as revenue
      FROM payments p
      GROUP BY DATE(p.created_at)
      ORDER BY day DESC
      LIMIT 30
    `);
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

router.get('/top-items', auth('admin'), async (req, res) => {
  try {
    const { rows } = await db.query(`
      SELECT i.name, SUM(oi.quantity) as qty
      FROM order_items oi JOIN items i ON oi.item_id=i.id
      GROUP BY i.name
      ORDER BY qty DESC
      LIMIT 10
    `);
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// Public endpoint for top items (for AI assistant)
router.get('/public/top-items', async (req, res) => {
  try {
    const { rows } = await db.query(`
      SELECT i.id, i.name, i.price, i.image_url, SUM(oi.quantity) as qty
      FROM order_items oi JOIN items i ON oi.item_id=i.id
      WHERE i.available = true
      GROUP BY i.id, i.name, i.price, i.image_url
      ORDER BY qty DESC
      LIMIT 5
    `);
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get total revenue
router.get('/total-revenue', auth('admin'), async (req, res) => {
  try {
    const { rows } = await db.query(`
      SELECT COALESCE(SUM(amount), 0) as total_revenue
      FROM payments
    `);
    res.json(rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get number of days with revenue
router.get('/revenue-days', auth('admin'), async (req, res) => {
  try {
    const { rows } = await db.query(`
      SELECT COUNT(DISTINCT DATE(created_at)) as revenue_days
      FROM payments
    `);
    res.json(rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get revenue for last 30 days (anchored to latest payment date)
router.get('/revenue-last-30-days', auth('admin'), async (req, res) => {
  try {
    const { rows } = await db.query(`
      WITH bounds AS (
        SELECT 
          COALESCE(
            MAX(DATE(created_at)),
            CURRENT_DATE
          ) AS end_day
        FROM payments
        WHERE status = 'completed'
      ),
      days AS (
        SELECT generate_series(
          (SELECT end_day FROM bounds) - INTERVAL '29 days',
          (SELECT end_day FROM bounds),
          '1 day'::interval
        )::date AS day
      )
      SELECT 
        d.day,
        COALESCE(SUM(p.amount), 0) AS revenue
      FROM days d
      LEFT JOIN payments p 
        ON DATE(p.created_at) = d.day
        AND p.status = 'completed'
      GROUP BY d.day
      ORDER BY d.day DESC
    `);
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get total invoices and revenue for last calendar month
router.get('/last-month-summary', auth('admin'), async (req, res) => {
  try {
    const { rows } = await db.query(`
      SELECT 
        COALESCE(COUNT(*), 0) AS invoice_count,
        COALESCE(SUM(amount), 0) AS total_amount
      FROM payments
      WHERE status = 'completed'
        AND created_at >= date_trunc('month', CURRENT_DATE - INTERVAL '1 month')
        AND created_at < date_trunc('month', CURRENT_DATE)
    `);
    res.json(rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
