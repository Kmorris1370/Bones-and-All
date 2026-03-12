const express = require('express');
const router = express.Router();
const pool = require('../db');
const auth = require('../middleware/auth');

// POST /api/blocks — Create a new block
router.post('/', auth, async (req, res) => {
  const { name, block_type, display_order } = req.body;
  if (!name) return res.status(400).json({ error: 'Block name is required' });

  try {
    const result = await pool.query(
      `INSERT INTO blocks (user_id, name, block_type, display_order)
       VALUES ($1, $2, $3, $4) RETURNING *`,
      [req.userId, name, block_type || 'custom', display_order || 0]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/blocks — Get all blocks for logged in user
router.get('/', auth, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT * FROM blocks WHERE user_id = $1 ORDER BY display_order ASC`,
      [req.userId]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// PATCH /api/blocks/:id — Rename or reorder a block
router.patch('/:id', auth, async (req, res) => {
  const { name, display_order } = req.body;
  try {
    // Verify ownership
    const block = await pool.query(
      'SELECT * FROM blocks WHERE id = $1 AND user_id = $2',
      [req.params.id, req.userId]
    );
    if (block.rows.length === 0) return res.status(404).json({ error: 'Block not found' });

    const result = await pool.query(
      `UPDATE blocks SET
        name = COALESCE($1, name),
        display_order = COALESCE($2, display_order)
       WHERE id = $3 RETURNING *`,
      [name, display_order, req.params.id]
    );
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// DELETE /api/blocks/:id — Delete a block
router.delete('/:id', auth, async (req, res) => {
  try {
    const block = await pool.query(
      'SELECT * FROM blocks WHERE id = $1 AND user_id = $2',
      [req.params.id, req.userId]
    );
    if (block.rows.length === 0) return res.status(404).json({ error: 'Block not found' });

    await pool.query('DELETE FROM blocks WHERE id = $1', [req.params.id]);
    res.json({ message: 'Block deleted' });
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;