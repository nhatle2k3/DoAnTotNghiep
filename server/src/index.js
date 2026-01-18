/**
 * Server chính của ứng dụng Trình Café
 * - Khởi tạo Express server với CORS
 * - Đăng ký các routes API
 * - Cấu hình Socket.IO cho real-time notifications
 * - Serve static files (QR codes, order page)
 */
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');
const http = require('http');
const { Server } = require('socket.io');

dotenv.config();
const app = express();
const server = http.createServer(app);
const PORT = process.env.PORT || 4000;

// Cấu hình CORS
const allowOrigin = process.env.ALLOW_ORIGIN || '*';
const allowedOrigins = allowOrigin.split(',').map(s => s.trim()).filter(Boolean);

const corsOptions = {
  origin: function(origin, callback) {
    // Cho phép requests không có Origin header (non-browser) hoặc wildcard
    if (!origin || allowOrigin === '*') return callback(null, true);
    // Kiểm tra origin có trong danh sách allowed
    if (allowedOrigins.includes(origin)) return callback(null, true);
    return callback(new Error('Not allowed by CORS'));
  },
  credentials: true, // Cho phép gửi cookies/credentials
};

// Middleware
app.use(cors(corsOptions));
app.options('*', cors(corsOptions)); // Preflight requests
app.use(express.json()); // Parse JSON body

// Đăng ký các routes API
const authRoutes = require('./routes/auth');
const menuRoutes = require('./routes/menu');
const tablesRoutes = require('./routes/tables');
const ordersRoutes = require('./routes/orders');
const paymentsRoutes = require('./routes/payments');
const reportsRoutes = require('./routes/reports');
const usersRoutes = require('./routes/users');

app.use('/api/auth', authRoutes);      // Xác thực: login, register
app.use('/api/menu', menuRoutes);      // Menu: items, categories
app.use('/api/tables', tablesRoutes);  // Bàn: locations, tables
app.use('/api/orders', ordersRoutes);   // Đơn hàng: create, update status, get
app.use('/api/payments', paymentsRoutes); // Thanh toán
app.use('/api/reports', reportsRoutes);   // Báo cáo
app.use('/api/users', usersRoutes);    // Người dùng: customers, staff

// Healthcheck endpoint
app.get('/api/health', (req, res) => res.json({ ok: true }));

// Serve QR code images (nếu đã generate)
app.use('/qr', express.static(path.join(process.cwd(), process.env.QR_OUTPUT_DIR || 'qr_codes')));

// Serve public files (trang đặt món cho khách hàng)
app.use(express.static(path.join(process.cwd(), 'public')));

const QR_DIR = process.env.QR_OUTPUT_DIR || 'qr_codes';
const BIND_HOST = process.env.HOST || '0.0.0.0';

// Khởi tạo Socket.IO với cấu hình CORS
const io = new Server(server, {
  cors: {
    origin: allowedOrigins,
    methods: ["GET", "POST"],
    credentials: true
  }
});

/**
 * Xử lý kết nối Socket.IO
 * - Admin có thể join room 'admin' để nhận real-time notifications
 * - Các events: 'new-order', 'order-status-updated'
 */
io.on('connection', (socket) => {
  console.log(`📱 Client connected: ${socket.id}`);
  
  // Admin join room để nhận notifications
  socket.on('join-admin', () => {
    socket.join('admin');
    console.log(`👨‍💼 Admin joined: ${socket.id}`);
  });
  
  socket.on('disconnect', () => {
    console.log(`📱 Client disconnected: ${socket.id}`);
  });
});

// Lưu io instance vào app để các routes khác có thể sử dụng
app.set('io', io);

server.listen(PORT, BIND_HOST, () => {
  console.log(`Trinh Cafe API listening on ${BIND_HOST}:${PORT}`);
  console.log(`  - CORS ALLOW_ORIGIN = ${allowOrigin}`);
  console.log(`  - QR output dir = ${QR_DIR}`);
  console.log(`  - WebSocket enabled`);
  if (process.env.QR_HOST) console.log(`  - QR_HOST = ${process.env.QR_HOST}`);
});
