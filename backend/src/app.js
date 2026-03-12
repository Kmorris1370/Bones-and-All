require('dotenv').config();
const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/blocks', require('./routes/blocks'));
app.use('/api/questions', require('./routes/questions'));
app.use('/api/logs', require('./routes/logs'));
app.use('/api/questionnaire', require('./routes/questionnaire'));
app.use('/api/notifications', require('./routes/notifications'));
app.use('/api/profile', require('./routes/profile'));

// Health check
app.get('/health', async (req, res) => {
  const { rows } = await require('./db').query('SELECT NOW()');
  res.json({ db: 'connected', time: rows[0].now });
});

// Scheduled jobs
require('./jobs/dailyReminder');


// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'An unexpected error occurred' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));