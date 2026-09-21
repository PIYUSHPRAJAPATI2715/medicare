const express = require('express');
const cors = require('cors');
require('dotenv').config();

const apiRoutes = require('./src/routes/api.routes');

const app = express();
const PORT = process.env.PORT || 5050;

app.use(cors());
app.use(express.json());

// Healthcheck
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'MediCare+ Backend API Running', timestamp: new Date() });
});

// API Routes
app.use('/api', apiRoutes);

app.listen(PORT, () => {
  console.log(`=================================================`);
  console.log(`🚀 MediCare+ REST API Server running on port ${PORT}`);
  console.log(`🌐 Base URL: http://localhost:${PORT}/api`);
  console.log(`🎥 Agora RTC/RTM Token Service Ready`);
  console.log(`=================================================`);
});
