const http = require('http');
const express = require('express');
const cors = require('cors');
const config = require('./config');
const { setupWebSocketServer } = require('./websocket/socketServer');

const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const communityRoutes = require('./routes/communityRoutes');
const eventRoutes = require('./routes/eventRoutes');
const chatRoutes = require('./routes/chatRoutes');
const notificationRoutes = require('./routes/notificationRoutes');

const app = express();

app.use(cors());
app.use(express.json());

// Request logging middleware
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'CampusConnect API & WebSocket Server',
    timestamp: new Date().toISOString(),
  });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/communities', communityRoutes);
app.use('/api/events', eventRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/conversations', chatRoutes); // Supports /api/conversations alias
app.use('/api/notifications', notificationRoutes);

// Global Error Handler
app.use((err, req, res, next) => {
  console.error('Unhandled server error:', err);
  res.status(500).json({ error: 'Internal Server Error', message: err.message });
});

// Create HTTP and WebSocket Server
const server = http.createServer(app);
setupWebSocketServer(server);

if (require.main === module) {
  server.listen(config.PORT, () => {
    console.log(`===============================================`);
    console.log(`🚀 CampusConnect Backend Server Running!`);
    console.log(`📡 REST API: http://localhost:${config.PORT}/api`);
    console.log(`⚡ WebSocket: ws://localhost:${config.PORT}/ws`);
    console.log(`===============================================`);
  });
}

module.exports = { app, server };
