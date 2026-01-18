/**
 * Routes xử lý các API liên quan đến người dùng
 * - Lấy danh sách người dùng theo role (customer/staff)
 * - Tạo mới và sửa thông tin nhân viên
 * - Chỉ admin mới có quyền truy cập
 */
const express = require('express');
const router = express.Router();
const db = require('../db');
const bcrypt = require('bcryptjs');
const { auth } = require('../middleware/auth');

/**
 * GET /api/users?role=customer|staff
 * Lấy danh sách người dùng theo role - chỉ admin mới có quyền
 * Query params: role (bắt buộc) - 'customer' hoặc 'staff'
 * Nếu role=staff, sẽ join với bảng staff để lấy thông tin chi tiết
 */
router.get('/', auth('admin'), async (req, res) => {
  const { role } = req.query;

  if (!role || !['customer', 'staff'].includes(role)) {
    return res.status(400).json({ error: 'Role phải là customer hoặc staff' });
  }

  try {
    let rows;
    if (role === 'staff') {
      // Join với bảng staff để lấy thông tin chi tiết
      const result = await db.query(
        `SELECT 
          u.id, 
          u.full_name, 
          u.email, 
          u.role, 
          u.created_at,
          s.phone,
          s.position,
          s.salary,
          s.work_schedule,
          s.status,
          s.started_at
        FROM users u
        LEFT JOIN staff s ON u.id = s.user_id
        WHERE u.role = $1
        ORDER BY u.created_at DESC`,
        [role]
      );
      rows = result.rows;
    } else {
      const result = await db.query(
        `SELECT id, full_name, email, role, created_at
         FROM users
         WHERE role = $1
         ORDER BY created_at DESC`,
        [role]
      );
      rows = result.rows;
    }
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

/**
 * GET /api/users/:id
 * Lấy thông tin chi tiết của một user (để sửa)
 */
router.get('/:id', auth('admin'), async (req, res) => {
  const { id } = req.params;

  try {
    const result = await db.query(
      `SELECT 
        u.id, 
        u.full_name, 
        u.email, 
        u.role, 
        u.created_at,
        s.phone,
        s.position,
        s.salary,
        s.work_schedule,
        s.status,
        s.started_at
      FROM users u
      LEFT JOIN staff s ON u.id = s.user_id
      WHERE u.id = $1`,
      [id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Không tìm thấy người dùng' });
    }

    res.json(result.rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

/**
 * POST /api/users/staff
 * Tạo nhân viên mới - chỉ admin mới có quyền
 * Body: { full_name, email, password, phone, position, salary, work_schedule, status, started_at }
 */
router.post('/staff', auth('admin'), async (req, res) => {
  const { 
    full_name, 
    email, 
    password, 
    phone, 
    position, 
    salary, 
    work_schedule, 
    status = 'working',
    started_at 
  } = req.body;

  // Validation
  if (!full_name || !email || !password) {
    return res.status(400).json({ error: 'Họ tên, email và mật khẩu là bắt buộc' });
  }

  if (password.length < 6) {
    return res.status(400).json({ error: 'Mật khẩu phải có ít nhất 6 ký tự' });
  }

  try {
    // Check if email already exists
    const existingUser = await db.query('SELECT id FROM users WHERE email=$1', [email]);
    if (existingUser.rowCount > 0) {
      return res.status(400).json({ error: 'Email đã được sử dụng' });
    }

    // Hash password
    const password_hash = await bcrypt.hash(password, 10);

    // Start transaction
    await db.query('BEGIN');

    try {
      // Create user
      const userResult = await db.query(
        `INSERT INTO users (full_name, email, password_hash, role) 
         VALUES ($1, $2, $3, $4) 
         RETURNING id, full_name, email, role, created_at`,
        [full_name, email, password_hash, 'staff']
      );

      const userId = userResult.rows[0].id;

      // Create staff record
      await db.query(
        `INSERT INTO staff (user_id, phone, position, salary, work_schedule, status, started_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [userId, phone || null, position || null, salary || null, work_schedule || null, status, started_at || null]
      );

      await db.query('COMMIT');

      // Return created user with staff info
      const result = await db.query(
        `SELECT 
          u.id, 
          u.full_name, 
          u.email, 
          u.role, 
          u.created_at,
          s.phone,
          s.position,
          s.salary,
          s.work_schedule,
          s.status,
          s.started_at
        FROM users u
        LEFT JOIN staff s ON u.id = s.user_id
        WHERE u.id = $1`,
        [userId]
      );

      res.status(201).json(result.rows[0]);
    } catch (e) {
      await db.query('ROLLBACK');
      throw e;
    }
  } catch (e) {
    console.error(e);
    if (e.code === '23505') { // Unique violation
      return res.status(400).json({ error: 'Email đã được sử dụng' });
    }
    res.status(500).json({ error: 'Lỗi server. Vui lòng thử lại sau.' });
  }
});

/**
 * PUT /api/users/staff/:id
 * Cập nhật thông tin nhân viên - chỉ admin mới có quyền
 * Body: { full_name, email, password?, phone, position, salary, work_schedule, status, started_at }
 * Note: password là optional, chỉ cập nhật nếu được cung cấp
 */
router.put('/staff/:id', auth('admin'), async (req, res) => {
  const { id } = req.params;
  const { 
    full_name, 
    email, 
    password, 
    phone, 
    position, 
    salary, 
    work_schedule, 
    status,
    started_at 
  } = req.body;

  // Validation
  if (!full_name || !email) {
    return res.status(400).json({ error: 'Họ tên và email là bắt buộc' });
  }

  if (password && password.length < 6) {
    return res.status(400).json({ error: 'Mật khẩu phải có ít nhất 6 ký tự' });
  }

  try {
    // Check if user exists and is staff
    const userCheck = await db.query('SELECT id, role FROM users WHERE id=$1', [id]);
    if (userCheck.rowCount === 0) {
      return res.status(404).json({ error: 'Không tìm thấy nhân viên' });
    }
    if (userCheck.rows[0].role !== 'staff') {
      return res.status(400).json({ error: 'Người dùng này không phải là nhân viên' });
    }

    // Check if email is already used by another user
    const emailCheck = await db.query('SELECT id FROM users WHERE email=$1 AND id!=$2', [email, id]);
    if (emailCheck.rowCount > 0) {
      return res.status(400).json({ error: 'Email đã được sử dụng bởi người dùng khác' });
    }

    // Start transaction
    await db.query('BEGIN');

    try {
      // Update user
      if (password) {
        const password_hash = await bcrypt.hash(password, 10);
        await db.query(
          `UPDATE users SET full_name=$1, email=$2, password_hash=$3 WHERE id=$4`,
          [full_name, email, password_hash, id]
        );
      } else {
        await db.query(
          `UPDATE users SET full_name=$1, email=$2 WHERE id=$3`,
          [full_name, email, id]
        );
      }

      // Update or insert staff record
      const staffCheck = await db.query('SELECT id FROM staff WHERE user_id=$1', [id]);
      if (staffCheck.rowCount > 0) {
        // Update existing staff record
        await db.query(
          `UPDATE staff 
           SET phone=$1, position=$2, salary=$3, work_schedule=$4, status=$5, started_at=$6
           WHERE user_id=$7`,
          [phone || null, position || null, salary || null, work_schedule || null, status || 'working', started_at || null, id]
        );
      } else {
        // Insert new staff record
        await db.query(
          `INSERT INTO staff (user_id, phone, position, salary, work_schedule, status, started_at)
           VALUES ($1, $2, $3, $4, $5, $6, $7)`,
          [id, phone || null, position || null, salary || null, work_schedule || null, status || 'working', started_at || null]
        );
      }

      await db.query('COMMIT');

      // Return updated user with staff info
      const result = await db.query(
        `SELECT 
          u.id, 
          u.full_name, 
          u.email, 
          u.role, 
          u.created_at,
          s.phone,
          s.position,
          s.salary,
          s.work_schedule,
          s.status,
          s.started_at
        FROM users u
        LEFT JOIN staff s ON u.id = s.user_id
        WHERE u.id = $1`,
        [id]
      );

      res.json(result.rows[0]);
    } catch (e) {
      await db.query('ROLLBACK');
      throw e;
    }
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Lỗi server. Vui lòng thử lại sau.' });
  }
});

module.exports = router;


