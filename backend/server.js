const express = require('express');
const cors = require('cors');
require('dotenv').config();

const connectDB = require('./src/config/db');
const seedInitialData = require('./src/models/seed');
const apiRoutes = require('./src/routes/api.routes');

const app = express();
const PORT = process.env.PORT || 5050;

app.use(cors());
app.use(express.json());

// Request logger middleware
app.use((req, res, next) => {
  const start = Date.now();
  const timestamp = new Date().toLocaleTimeString();
  console.log(`[${timestamp}] 📥 [API IN] ${req.method} ${req.originalUrl}`);
  res.on('finish', () => {
    console.log(`[${timestamp}] 📤 [API OUT] ${req.method} ${req.originalUrl} -> ${res.statusCode} (${Date.now() - start}ms)`);
  });
  next();
});

// Healthcheck
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'MediCare+ Backend API Running', timestamp: new Date() });
});

// API Routes
app.use('/api', apiRoutes);

// Initialize DB and listen
const startServer = async () => {
  const isMongoConnected = await connectDB();
  if (isMongoConnected) {
    await seedInitialData();
  }

  app.listen(PORT, '0.0.0.0', () => {
    console.log(`=================================================`);
    console.log(`🚀 MediCare+ REST API Server running on port ${PORT}`);
    console.log(`🌐 Base URL: http://0.0.0.0:${PORT}/api`);
    console.log(`🌐 Local URL: http://localhost:${PORT}/api`);
    console.log(`🎥 Agora RTC/RTM Token Service Ready`);
    console.log(`=================================================`);
  });
};

startServer();

