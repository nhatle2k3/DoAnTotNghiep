const express = require('express');
const router = express.Router();
const db = require('../db');
const { auth } = require('../middleware/auth');

router.post('/', auth(), async (req, res) => {
  const { order_id, method } = req.body;
  
  // Validate input
  if (!order_id || !method) {
    return res.status(400).json({ 
      error: 'Missing required fields', 
      required: ['order_id', 'method'] 
    });
  }
  
  // Validate payment method
  const validMethods = ['cash', 'card', 'ewallet'];
  if (!validMethods.includes(method)) {
    return res.status(400).json({ 
      error: 'Invalid payment method', 
      validMethods: validMethods 
    });
  }
  
  // Validate order ID
  if (isNaN(parseInt(order_id))) {
    return res.status(400).json({ error: 'Invalid order ID' });
  }
  
  const client = await db.pool.connect();
  try {
    await client.query('BEGIN');
    
    // Check if order exists and get details
    const { rows: ordRows } = await client.query(`
      SELECT o.id, o.total, o.status, t.table_number
      FROM orders o 
      JOIN cafe_tables t ON o.table_id = t.id
      WHERE o.id = $1
    `, [order_id]);
    
    if (ordRows.length === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }
    
    const order = ordRows[0];
    
    // Check if order is already paid
    if (order.status === 'paid') {
      return res.status(400).json({ error: 'Order is already paid' });
    }
    
    // Check if order can be paid (must be served or ready)
    if (!['served', 'ready'].includes(order.status)) {
      return res.status(400).json({ 
        error: 'Order cannot be paid yet', 
        currentStatus: order.status,
        requiredStatus: 'served or ready'
      });
    }
    
    const amount = order.total;
    
    // Create payment record
    const { rows } = await client.query(
      'INSERT INTO payments (order_id, amount, method, status) VALUES ($1,$2,$3,$4) RETURNING id, created_at',
      [order_id, amount, method, 'completed']
    );
    
    // Update order status to paid
    await client.query('UPDATE orders SET status=$1 WHERE id=$2', ['paid', order_id]);
    
    await client.query('COMMIT');
    
    // Emit payment success event to admin clients
    const io = req.app.get('io');
    if (io) {
      io.to('admin').emit('payment-completed', {
        orderId: order_id,
        tableNumber: order.table_number,
        amount: amount,
        method: method,
        paymentId: rows[0].id,
        paidAt: rows[0].created_at
      });
      console.log(`💰 Payment completed notification sent: Order #${order_id}, Table ${order.table_number}, Amount: ${amount}, Method: ${method}`);
    }
    
    res.status(201).json({ 
      id: rows[0].id, 
      amount, 
      method, 
      orderId: order_id,
      tableNumber: order.table_number,
      paidAt: rows[0].created_at
    });
  } catch (e) {
    await client.query('ROLLBACK');
    console.error('Payment error:', e);
    res.status(500).json({ error: 'Server error' });
  } finally {
    client.release();
  }
});

// Get payment history
router.get('/history', auth(), async (req, res) => {
  try {
    const { limit = 50, offset = 0 } = req.query;
    
    const { rows } = await db.query(`
      SELECT 
        p.id,
        p.amount,
        p.method,
        p.status,
        p.created_at as paid_at,
        o.id as order_id,
        o.total as order_total,
        t.table_number
      FROM payments p
      JOIN orders o ON p.order_id = o.id
      JOIN cafe_tables t ON o.table_id = t.id
      ORDER BY p.created_at DESC
      LIMIT $1 OFFSET $2
    `, [parseInt(limit), parseInt(offset)]);
    
    res.json(rows);
  } catch (e) {
    console.error('Error fetching payment history:', e);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get payment statistics
router.get('/stats', auth(), async (req, res) => {
  try {
    const { rows } = await db.query(`
      SELECT 
        COUNT(*) as total_payments,
        SUM(amount) as total_revenue,
        AVG(amount) as average_payment,
        COUNT(CASE WHEN method = 'cash' THEN 1 END) as cash_payments,
        COUNT(CASE WHEN method = 'card' THEN 1 END) as card_payments,
        COUNT(CASE WHEN method = 'ewallet' THEN 1 END) as ewallet_payments
      FROM payments
      WHERE status = 'completed'
    `);
    
    res.json(rows[0]);
  } catch (e) {
    console.error('Error fetching payment stats:', e);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
