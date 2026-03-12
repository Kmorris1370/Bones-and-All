const express = require('express');
const router = express.Router();
const pool = require('../db');
const auth = require('../middleware/auth');

// POST /api/logs — Create a new log entry
router.post('/', auth, async (req, res) => {
  const { block_id, log_date, journal_entry } = req.body;

  if (!block_id) {
    return res.status(400).json({ error: 'block_id is required' });
  }

  try {
    // Verify block belongs to user
    const block = await pool.query(
      'SELECT id FROM blocks WHERE id = $1 AND user_id = $2',
      [block_id, req.userId]
    );
    if (block.rows.length === 0) {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    const result = await pool.query(
      `INSERT INTO logs (user_id, block_id, log_date, journal_entry)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (user_id, block_id, log_date, entry_number)
       DO UPDATE SET journal_entry = EXCLUDED.journal_entry
       RETURNING *`,
      [req.userId, block_id, log_date || new Date().toISOString().split('T')[0], journal_entry || null]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/logs/:blockId — Get all logs for a block
router.get('/:blockId', auth, async (req, res) => {
  try {
    // Verify block belongs to user
    const block = await pool.query(
      'SELECT id FROM blocks WHERE id = $1 AND user_id = $2',
      [req.params.blockId, req.userId]
    );
    if (block.rows.length === 0) {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    const result = await pool.query(
      `SELECT * FROM logs WHERE block_id = $1 AND user_id = $2 ORDER BY log_date DESC`,
      [req.params.blockId, req.userId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/logs/:blockId/:date — Get a specific log by date
router.get('/:blockId/:date', auth, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT * FROM logs WHERE block_id = $1 AND user_id = $2 AND log_date = $3`,
      [req.params.blockId, req.userId, req.params.date]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Log not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// PATCH /api/logs/:id — Update journal entry
router.patch('/:id', auth, async (req, res) => {
  const { journal_entry } = req.body;
  try {
    const log = await pool.query(
      'SELECT * FROM logs WHERE id = $1 AND user_id = $2',
      [req.params.id, req.userId]
    );
    if (log.rows.length === 0) {
      return res.status(404).json({ error: 'Log not found' });
    }

    const result = await pool.query(
      `UPDATE logs SET journal_entry = $1 WHERE id = $2 RETURNING *`,
      [journal_entry, req.params.id]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// DELETE /api/logs/:id — Delete a log
router.delete('/:id', auth, async (req, res) => {
  try {
    const log = await pool.query(
      'SELECT * FROM logs WHERE id = $1 AND user_id = $2',
      [req.params.id, req.userId]
    );
    if (log.rows.length === 0) {
      return res.status(404).json({ error: 'Log not found' });
    }

    await pool.query('DELETE FROM logs WHERE id = $1', [req.params.id]);
    res.json({ message: 'Log deleted' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;