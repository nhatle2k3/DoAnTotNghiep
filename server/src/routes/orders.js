const express = require('express');
const router = express.Router();
const db = require('../db');
const { auth } = require('../middleware/auth');

// Create order - requires authentication
router.post('/', auth(), async (req, res) => {
  const { table_id, items } = req.body; // items: [{item_id, quantity}]
  const client = await db.pool.connect();
  try {
    await client.query('BEGIN');
    const { rows: orderRows } = await client.query(
      'INSERT INTO orders (table_id, status) VALUES ($1,$2) RETURNING id, created_at',
      [table_id, 'pending']
    );
    const orderId = orderRows[0].id;
    let total = 0;
    for (const it of items) {
      const { rows: itemRows } = await client.query('SELECT price FROM items WHERE id=$1', [it.item_id]);
      if (itemRows.length === 0) throw new Error('Item not found');
      const price = itemRows[0].price;
      total += price * it.quantity;
      await client.query(
        'INSERT INTO order_items (order_id, item_id, quantity, price) VALUES ($1,$2,$3,$4)',
        [orderId, it.item_id, it.quantity, price]
      );
    }
    await client.query('UPDATE orders SET total=$1 WHERE id=$2', [total, orderId]);
    
    // Update table status from 'available' to 'occupied' when order is created
    await client.query(
      `UPDATE cafe_tables 
       SET status='occupied' 
       WHERE id=$1 AND status='available'`,
      [table_id]
    );
    
    await client.query('COMMIT');
    
    // Emit new order event to admin clients
    const io = req.app.get('io');
    if (io) {
      // Get order details with table info for the notification
      const { rows: orderDetails } = await client.query(`
        SELECT o.id, o.table_id, o.status, o.total, o.created_at, t.table_number
        FROM orders o JOIN cafe_tables t ON o.table_id=t.id
        WHERE o.id=$1
      `, [orderId]);
      
      if (orderDetails.length > 0) {
        io.to('admin').emit('new-order', orderDetails[0]);
        console.log(`📢 New order notification sent: Order #${orderId}, Table ${orderDetails[0].table_number}`);
      }
    }
    
    res.status(201).json({ id: orderId, total });
  } catch (e) {
    await client.query('ROLLBACK');
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  } finally {
    client.release();
  }
});

// Update order status
router.put('/:id/status', auth(), async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  
  // Validate status
  const validStatuses = ['pending', 'preparing', 'ready', 'served', 'paid', 'cancelled'];
  if (!status || !validStatuses.includes(status)) {
    return res.status(400).json({ 
      error: 'Invalid status', 
      validStatuses: validStatuses 
    });
  }
  
  // Validate order ID
  if (!id || isNaN(parseInt(id))) {
    return res.status(400).json({ error: 'Invalid order ID' });
  }
  
  try {
    // Check if order exists
    const { rows: orderRows } = await db.query(
      'SELECT id, status FROM orders WHERE id=$1', 
      [id]
    );
    
    if (orderRows.length === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }
    
    const currentStatus = orderRows[0].status;
    
    // Emit status update event to admin clients
    const io = req.app.get('io');
    if (io) {
      // Get order details with table info for the notification
      const { rows: orderDetails } = await db.query(`
        SELECT o.id, o.table_id, o.status, o.total, o.created_at, t.table_number
        FROM orders o JOIN cafe_tables t ON o.table_id=t.id
        WHERE o.id=$1
      `, [id]);
      
      if (orderDetails.length > 0) {
        io.to('admin').emit('order-status-updated', {
          ...orderDetails[0],
          oldStatus: currentStatus,
          newStatus: status
        });
        console.log(`📢 Order status update notification sent: Order #${id}, Table ${orderDetails[0].table_number}, ${currentStatus} -> ${status}`);
      }
    }
    
    // Update the order status
    await db.query('UPDATE orders SET status=$1 WHERE id=$2', [status, id]);
    
    res.json({ 
      ok: true, 
      orderId: id, 
      oldStatus: currentStatus, 
      newStatus: status 
    });
  } catch (e) {
    console.error('Error updating order status:', e);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get current open orders
router.get('/open', async (req, res) => {
  try {
    const { rows } = await db.query(`
      SELECT o.id, o.table_id, o.status, o.total, o.created_at, t.table_number
      FROM orders o JOIN cafe_tables t ON o.table_id=t.id
      WHERE o.status NOT IN ('paid','cancelled')
      ORDER BY o.created_at DESC
    `);
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get orders by table_id (for user to view their orders)
router.get('/table/:table_id', async (req, res) => {
  try {
    const { table_id } = req.params;
    
    // Validate table_id
    if (!table_id || isNaN(parseInt(table_id))) {
      return res.status(400).json({ error: 'Invalid table ID' });
    }
    
    const tableIdInt = parseInt(table_id);
    console.log(`📋 Fetching orders for table_id: ${tableIdInt}`);
    
    const { rows } = await db.query(`
      SELECT o.id, o.table_id, o.status, o.total, o.created_at, t.table_number, l.name as location_name, l.code as location_code
      FROM orders o 
      JOIN cafe_tables t ON o.table_id=t.id
      JOIN locations l ON t.location_id=l.id
      WHERE o.table_id=$1
      ORDER BY o.created_at DESC
    `, [tableIdInt]);
    
    console.log(`📋 Found ${rows.length} orders for table_id: ${tableIdInt}`);
    res.json(rows);
  } catch (e) {
    console.error('Error fetching orders by table_id:', e);
    res.status(500).json({ error: 'Server error', details: e.message });
  }
});

// Get orders by location (for user to view all their orders in a location)
router.get('/location/:location_code', async (req, res) => {
  try {
    const { location_code } = req.params;
    
    if (!location_code) {
      return res.status(400).json({ error: 'Invalid location code' });
    }
    
    console.log(`📋 Fetching orders for location: ${location_code}`);
    
    const { rows } = await db.query(`
      SELECT o.id, o.table_id, o.status, o.total, o.created_at, 
             t.table_number, l.name as location_name, l.code as location_code
      FROM orders o 
      JOIN cafe_tables t ON o.table_id=t.id
      JOIN locations l ON t.location_id=l.id
      WHERE l.code=$1
      ORDER BY o.created_at DESC
      LIMIT 50
    `, [location_code]);
    
    console.log(`📋 Found ${rows.length} orders for location: ${location_code}`);
    res.json(rows);
  } catch (e) {
    console.error('Error fetching orders by location:', e);
    res.status(500).json({ error: 'Server error', details: e.message });
  }
});

// Get order details with items
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Get order basic info
    const { rows: orderRows } = await db.query(`
      SELECT o.id, o.table_id, o.status, o.total, o.created_at, t.table_number
      FROM orders o JOIN cafe_tables t ON o.table_id=t.id
      WHERE o.id=$1
    `, [id]);
    
    if (orderRows.length === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }
    
    // Get order items
    const { rows: itemRows } = await db.query(`
      SELECT oi.item_id, oi.quantity, oi.price, i.name
      FROM order_items oi JOIN items i ON oi.item_id=i.id
      WHERE oi.order_id=$1
      ORDER BY i.name
    `, [id]);
    
    const order = orderRows[0];
    order.items = itemRows;
    
    res.json(order);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
