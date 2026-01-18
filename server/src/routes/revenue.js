const express = require('express');
const router = express.Router();
const pool = require('../db'); // file connect PostgreSQL

router.get('/30-days', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
          to_char(p.created_at, 'YYYY-MM-DD') AS date,
          SUM(p.amount) AS revenue
      FROM payments p
      WHERE p.status = 'completed'
        AND p.created_at >= NOW() - INTERVAL '30 days'
      GROUP BY 1
      ORDER BY 1;
    `);

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

module.exports = router;
