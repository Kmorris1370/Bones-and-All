const cron = require('node-cron');
const pool = require('../db');
const { sendNotification } = require('../services/fcm');

// Runs every minute - checks which users should be notified now
cron.schedule('* * * * *', async () => {
  const now = new Date();
  const currentTime = `${String(now.getHours()).padStart(2,'0')}:${String(now.getMinutes()).padStart(2,'0')}`;

  const { rows } = await pool.query(
    `SELECT id, fcm_token FROM users
     WHERE notifications_enabled = TRUE
     AND fcm_token IS NOT NULL
     AND TO_CHAR(notification_time, 'HH24:MI') = $1`,
    [currentTime]
  );

  for (const user of rows) {
    await sendNotification(
      user.fcm_token,
      'Bones and All',
      'Time to fill out your daily questionnaire!'
    );
  }
});