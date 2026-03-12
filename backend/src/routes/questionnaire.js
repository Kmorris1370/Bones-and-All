const express = require('express');
const router = express.Router();
const pool = require('../db');
const auth = require('../middleware/auth');

// POST /api/questionnaire — Save responses for a log
router.post('/', auth, async (req, res) => {
  const { log_id, responses } = req.body;
  // responses should be an array: [{ question_id, response_value }]

  if (!log_id || !responses || !Array.isArray(responses)) {
    return res.status(400).json({ error: 'log_id and responses array are required' });
  }

  try {
    // Verify log belongs to user
    const log = await pool.query(
      'SELECT * FROM logs WHERE id = $1 AND user_id = $2',
      [log_id, req.userId]
    );
    if (log.rows.length === 0) {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    // Insert all responses
    const inserted = [];
    for (const r of responses) {
      const result = await pool.query(
        `INSERT INTO questionnaire_responses (log_id, question_id, response_value)
         VALUES ($1, $2, $3)
         ON CONFLICT (log_id, question_id)
         DO UPDATE SET response_value = EXCLUDED.response_value
         RETURNING *`,
        [log_id, r.question_id, r.response_value]
      );
      inserted.push(result.rows[0]);
    }

    res.status(201).json(inserted);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/questionnaire/:logId — Get all responses for a log
router.get('/:logId', auth, async (req, res) => {
  try {
    // Verify log belongs to user
    const log = await pool.query(
      'SELECT * FROM logs WHERE id = $1 AND user_id = $2',
      [req.params.logId, req.userId]
    );
    if (log.rows.length === 0) {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    const result = await pool.query(
      `SELECT qr.*, q.question_text, q.question_type
       FROM questionnaire_responses qr
       JOIN questions q ON qr.question_id = q.id
       WHERE qr.log_id = $1`,
      [req.params.logId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;