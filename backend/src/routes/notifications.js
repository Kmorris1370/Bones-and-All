const express = require('express');
const router = express.Router();
const pool = require('../db');
const auth = require('../middleware/auth');

// PATCH /api/notifications/preferences — Update notification settings
router.patch('/preferences', auth, async (req, res) => {
  const { notifications_enabled, notification_time, fcm_token } = req.body;

  try {
    const result = await pool.query(
      `UPDATE users SET
        notifications_enabled = COALESCE($1, notifications_enabled),
        notification_time = COALESCE($2, notification_time),
        fcm_token = COALESCE($3, fcm_token)
       WHERE id = $4 RETURNING id, notifications_enabled, notification_time, fcm_token`,
      [notifications_enabled, notification_time, fcm_token, req.userId]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/notifications/preferences — Get current notification settings
router.get('/preferences', auth, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT notifications_enabled, notification_time, fcm_token FROM users WHERE id = $1`,
      [req.userId]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/notifications/history — Get notification history for user
router.get('/history', auth, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT * FROM notifications WHERE user_id = $1 ORDER BY sent_at DESC LIMIT 50`,
      [req.userId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;