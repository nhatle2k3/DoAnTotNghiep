const express = require('express');
const router = express.Router();
const db = require('../db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');
dotenv.config();

router.post('/register', async (req, res) => {
  const { full_name, email, password } = req.body;
  
  // Validation
  if (!full_name || !email || !password) {
    return res.status(400).json({ error: 'Vui lòng điền đầy đủ thông tin' });
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
    
    // Create user with role 'customer'
    const result = await db.query(
      'INSERT INTO users (full_name, email, password_hash, role) VALUES ($1, $2, $3, $4) RETURNING id, full_name, email, role',
      [full_name, email, password_hash, 'customer']
    );
    
    const user = result.rows[0];
    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role, name: user.full_name },
      process.env.JWT_SECRET,
      { expiresIn: '12h' }
    );
    
    res.status(201).json({
      token,
      user: { id: user.id, email: user.email, role: user.role, name: user.full_name }
    });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Lỗi server. Vui lòng thử lại sau.' });
  }
});

router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  
  if (!email || !password) {
    return res.status(400).json({ error: 'Vui lòng nhập email và mật khẩu' });
  }
  
  try {
    const result = await db.query('SELECT id, full_name, email, password_hash, role FROM users WHERE email=$1', [email]);
    if (result.rowCount === 0) return res.status(401).json({ error: 'Email hoặc mật khẩu không đúng' });
    const user = result.rows[0];
    const ok = await bcrypt.compare(password, user.password_hash);
    if (!ok) return res.status(401).json({ error: 'Email hoặc mật khẩu không đúng' });
    const token = jwt.sign({ id: user.id, email: user.email, role: user.role, name: user.full_name }, process.env.JWT_SECRET, { expiresIn: '12h' });
    res.json({ token, user: { id: user.id, email: user.email, role: user.role, name: user.full_name } });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Lỗi server. Vui lòng thử lại sau.' });
  }
});

module.exports = router;
