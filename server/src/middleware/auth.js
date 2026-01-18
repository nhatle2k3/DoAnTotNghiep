/**
 * Middleware xác thực người dùng bằng JWT
 * - Kiểm tra token trong header Authorization
 * - Xác minh token và giải mã payload
 * - Kiểm tra quyền truy cập theo role (nếu có yêu cầu)
 */
const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');
dotenv.config();

/**
 * Middleware xác thực
 * @param {string|null} requiredRole - Role bắt buộc (null = chỉ cần đăng nhập, 'admin' = chỉ admin)
 * @returns {Function} Express middleware function
 */
function auth(requiredRole = null) {
  return (req, res, next) => {
    // Lấy token từ header Authorization
    const header = req.headers.authorization || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;
    
    // Kiểm tra token có tồn tại
    if (!token) return res.status(401).json({ error: 'Unauthorized' });
    
    try {
      // Xác minh và giải mã token
      const payload = jwt.verify(token, process.env.JWT_SECRET);
      req.user = payload; // Gắn thông tin user vào request
      
      // Kiểm tra quyền truy cập theo role (nếu có yêu cầu)
      if (requiredRole && payload.role !== requiredRole) {
        return res.status(403).json({ error: 'Forbidden' });
      }
      
      next(); // Cho phép tiếp tục xử lý request
    } catch (e) {
      // Token không hợp lệ hoặc đã hết hạn
      return res.status(401).json({ error: 'Invalid token' });
    }
  };
}

module.exports = { auth };
