const express = require('express');
const router = express.Router();
const pool = require('../db');
const auth = require('../middleware/auth');

// Helper — verify block belongs to user
const verifyBlockOwnership = async (blockId, userId) => {
  const result = await pool.query(
    'SELECT id FROM blocks WHERE id = $1 AND user_id = $2',
    [blockId, userId]
  );
  return result.rows.length > 0;
};

// POST /api/questions — Add a question to a block
router.post('/', auth, async (req, res) => {
  const { block_id, question_text, question_type, display_order } = req.body;
  if (!block_id || !question_text) {
    return res.status(400).json({ error: 'block_id and question_text are required' });
  }

  try {
    const owned = await verifyBlockOwnership(block_id, req.userId);
    if (!owned) return res.status(403).json({ error: 'Unauthorized' });

    const result = await pool.query(
      `INSERT INTO questions (block_id, question_text, question_type, display_order)
       VALUES ($1, $2, $3, $4) RETURNING *`,
      [block_id, question_text, question_type || 'text', display_order || 0]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/questions/:blockId — Get all questions for a block
router.get('/:blockId', auth, async (req, res) => {
  try {
    const owned = await verifyBlockOwnership(req.params.blockId, req.userId);
    if (!owned) return res.status(403).json({ error: 'Unauthorized' });

    const result = await pool.query(
      'SELECT * FROM questions WHERE block_id = $1 ORDER BY display_order ASC',
      [req.params.blockId]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// PATCH /api/questions/:id — Edit a question
router.patch('/:id', auth, async (req, res) => {
  const { question_text, display_order } = req.body;
  try {
    const q = await pool.query(
      `SELECT q.* FROM questions q
       JOIN blocks b ON q.block_id = b.id
       WHERE q.id = $1 AND b.user_id = $2`,
      [req.params.id, req.userId]
    );
    if (q.rows.length === 0) return res.status(404).json({ error: 'Question not found' });

    const result = await pool.query(
      `UPDATE questions SET
        question_text = COALESCE($1, question_text),
        display_order = COALESCE($2, display_order)
       WHERE id = $3 RETURNING *`,
      [question_text, display_order, req.params.id]
    );
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// DELETE /api/questions/:id — Delete a question
router.delete('/:id', auth, async (req, res) => {
  try {
    const q = await pool.query(
      `SELECT q.* FROM questions q
       JOIN blocks b ON q.block_id = b.id
       WHERE q.id = $1 AND b.user_id = $2`,
      [req.params.id, req.userId]
    );
    if (q.rows.length === 0) return res.status(404).json({ error: 'Question not found' });

    await pool.query('DELETE FROM questions WHERE id = $1', [req.params.id]);
    res.json({ message: 'Question deleted' });
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;