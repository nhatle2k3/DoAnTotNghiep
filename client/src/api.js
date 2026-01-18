/**
 * Utility function để gọi API
 * - Tự động xử lý base URL (có thể cấu hình qua VITE_API_BASE hoặc tự động detect)
 * - Hỗ trợ thêm token xác thực vào header
 * - Xử lý lỗi và trả về thông báo lỗi từ server
 */

// Xác định base URL của API
// Nếu có VITE_API_BASE trong env, dùng nó
// Ngược lại, tự động detect từ hostname hiện tại (hữu ích cho mobile devices truy cập qua IP)
const API_BASE = import.meta.env.VITE_API_BASE || `${location.protocol}//${location.hostname}:4000/api`;

/**
 * Gọi API endpoint
 * @param {string} path - Đường dẫn API (ví dụ: '/orders', '/menu')
 * @param {Object} options - Tùy chọn
 * @param {string} options.method - HTTP method (GET, POST, PUT, DELETE)
 * @param {Object} options.body - Body data (sẽ được stringify thành JSON)
 * @param {string} options.token - JWT token để xác thực
 * @returns {Promise<Object>} JSON response từ server
 * @throws {Error} Nếu request thất bại
 */
export async function api(path, { method='GET', body, token } = {}) {
  const res = await fetch(`${API_BASE}${path}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      // Thêm token vào header Authorization nếu có
      ...(token ? { 'Authorization': `Bearer ${token}` } : {})
    },
    body: body ? JSON.stringify(body) : undefined
  });
  
  // Xử lý lỗi HTTP
  if (!res.ok) {
    let msg = 'Request failed';
    try { 
      // Thử parse error message từ response JSON
      const j = await res.json(); 
      msg = j.error || msg; 
    } catch {
      // Nếu không parse được JSON, dùng message mặc định
    }
    throw new Error(msg);
  }
  
  // Trả về JSON data
  return res.json();
}
