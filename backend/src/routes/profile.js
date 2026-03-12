const express = require('express');
const router = express.Router();
const pool = require('../db');
const auth = require('../middleware/auth');

// GET /api/profile — Get user profile
router.get('/', auth, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, email, display_name, profile_picture_url, created_at FROM users WHERE id = $1`,
      [req.userId]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// PATCH /api/profile — Update profile
router.patch('/', auth, async (req, res) => {
  const { display_name, profile_picture_url } = req.body;
  try {
    const result = await pool.query(
      `UPDATE users SET
        display_name = COALESCE($1, display_name),
        profile_picture_url = COALESCE($2, profile_picture_url)
       WHERE id = $3 RETURNING id, email, display_name, profile_picture_url`,
      [display_name, profile_picture_url, req.userId]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// DELETE /api/profile — Delete account
router.delete('/', auth, async (req, res) => {
  try {
    await pool.query('DELETE FROM users WHERE id = $1', [req.userId]);
    res.json({ message: 'Account deleted successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;