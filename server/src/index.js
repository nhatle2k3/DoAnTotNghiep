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
const allowOrigin = process.env.ALLOW_ORIGIN || '*';
const allowedOrigins = allowOrigin.split(',').map(s => s.trim()).filter(Boolean);

const corsOptions = {
  origin: function(origin, callback) {
    // Allow non-browser requests (no Origin header), or wildcard
    if (!origin || allowOrigin === '*') return callback(null, true);
    if (allowedOrigins.includes(origin)) return callback(null, true);
    return callback(new Error('Not allowed by CORS'));
  },
  credentials: true,
};

app.use(cors(corsOptions));
app.options('*', cors(corsOptions));
app.use(express.json());

// Routes
const authRoutes = require('./routes/auth');
const menuRoutes = require('./routes/menu');
const tablesRoutes = require('./routes/tables');
const ordersRoutes = require('./routes/orders');
const paymentsRoutes = require('./routes/payments');
const reportsRoutes = require('./routes/reports');

app.use('/api/auth', authRoutes);
app.use('/api/menu', menuRoutes);
app.use('/api/tables', tablesRoutes);
app.use('/api/orders', ordersRoutes);
app.use('/api/payments', paymentsRoutes);
app.use('/api/reports', reportsRoutes);

// Healthcheck
app.get('/api/health', (req, res) => res.json({ ok: true }));

// Serve QR images if generated
app.use('/qr', express.static(path.join(process.cwd(), process.env.QR_OUTPUT_DIR || 'qr_codes')));

// Serve public files (order page)
app.use(express.static(path.join(process.cwd(), 'public')));

const QR_DIR = process.env.QR_OUTPUT_DIR || 'qr_codes';
const BIND_HOST = process.env.HOST || '0.0.0.0';

// Initialize Socket.IO with CORS configuration
const io = new Server(server, {
  cors: {
    origin: allowedOrigins,
    methods: ["GET", "POST"],
    credentials: true
  }
});

// Socket.IO connection handling
io.on('connection', (socket) => {
  console.log(`📱 Client connected: ${socket.id}`);
  
  socket.on('join-admin', () => {
    socket.join('admin');
    console.log(`👨‍💼 Admin joined: ${socket.id}`);
  });
  
  socket.on('disconnect', () => {
    console.log(`📱 Client disconnected: ${socket.id}`);
  });
});

// Make io available globally for other modules
app.set('io', io);

server.listen(PORT, BIND_HOST, () => {
  console.log(`Trinh Cafe API listening on ${BIND_HOST}:${PORT}`);
  console.log(`  - CORS ALLOW_ORIGIN = ${allowOrigin}`);
  console.log(`  - QR output dir = ${QR_DIR}`);
  console.log(`  - WebSocket enabled`);
  if (process.env.QR_HOST) console.log(`  - QR_HOST = ${process.env.QR_HOST}`);
});
