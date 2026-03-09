require('dotenv').config();
const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

// Routes (add as you build them)
// app.use('/api/auth', require('./routes/auth'));
// app.use('/api/logs', require('./routes/logs'));
// app.use('/api/notifications', require('./routes/notifications'));

// Scheduled jobs
require('./jobs/dailyReminder');

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

app.get('/health', async (req, res) => {
  const { rows } = await require('./db').query('SELECT NOW()');
  res.json({ db: 'connected', time: rows[0].now });
});