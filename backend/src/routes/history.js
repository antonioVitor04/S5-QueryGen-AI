const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const db = require('../db/connection');

router.get('/historico', authMiddleware, async (req, res) => {
  const [rows] = await db.query(
    'SELECT id, pergunta, sql_gerado, created_at FROM historico WHERE user_id = ? ORDER BY created_at DESC',
    [req.user.id]
  );
  res.json(rows);
});

router.delete('/historico/:id', authMiddleware, async (req, res) => {
  await db.query(
    'DELETE FROM historico WHERE id = ? AND user_id = ?',
    [req.params.id, req.user.id]
  );
  res.json({ mensagem: 'Deletado com sucesso' });
});

module.exports = router;