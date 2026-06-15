const express = require('express');
const router  = express.Router();
const authMiddleware = require('../middleware/auth');
const db = require('../db/connection');

router.get('/historico', authMiddleware, async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT id, pergunta, sql_gerado, grafico, eixo_x, eixo_y,
              descricao, created_at
       FROM historico
       WHERE user_id = ?
       ORDER BY created_at DESC`,
      [req.user.id]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ erro: 'Erro ao buscar histórico' });
  }
});

router.get('/historico/:id/dados', authMiddleware, async (req, res) => {
  try {
    // Busca o registro do histórico
    const [rows] = await db.query(
      `SELECT sql_gerado, grafico, eixo_x, eixo_y, descricao
       FROM historico WHERE id = ? AND user_id = ?`,
      [req.params.id, req.user.id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ erro: 'Registro não encontrado' });
    }

    const registro = rows[0];

    // Defesa extra: só reexecuta consultas de leitura (buildSQL sempre gera SELECT).
    if (!/^\s*SELECT\s/i.test(registro.sql_gerado)) {
      return res.status(400).json({ erro: 'Consulta armazenada inválida' });
    }

    const [dados] = await db.query(registro.sql_gerado);
    return res.json({
      dados,
      grafico:   registro.grafico,
      eixo_x:    registro.eixo_x,
      eixo_y:    registro.eixo_y,
      descricao: registro.descricao,
    });
  } catch (err) {
    return res.status(500).json({ erro: 'Erro ao executar consulta' });
  }
});

router.delete('/historico/:id', authMiddleware, async (req, res) => {
  try {
    const [result] = await db.query(
      'DELETE FROM historico WHERE id = ? AND user_id = ?',
      [req.params.id, req.user.id]
    );
    if (result.affectedRows === 0) {
      return res.status(404).json({ erro: 'Registro não encontrado' });
    }
    res.json({ mensagem: 'Deletado com sucesso' });
  } catch (err) {
    res.status(500).json({ erro: 'Erro ao deletar registro' });
  }
});

module.exports = router;