const crypto = require('crypto');
const db = require('../db/connection');
const bcrypt = require('bcrypt');
const { enviarEmailRecuperacao } = require('../services/emailService');

function gerarToken() {
  return crypto.randomInt(100000, 1000000).toString();
}

async function solicitarRecuperacao(req, res) {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ erro: 'E-mail obrigatório' });

    // Limpeza oportunista de tokens expirados/usados, evitando acúmulo
    // indefinido na tabela.
    await db.query('DELETE FROM tokens_recuperacao WHERE usado = TRUE OR expira_em < NOW()');

    const [rows] = await db.query(
      'SELECT id FROM usuarios WHERE email = ?', [email]
    );

    // Mensagem genérica independente do e-mail existir ou não, para evitar
    // que a resposta seja usada para descobrir quais e-mails estão cadastrados.
    if (rows.length > 0) {
      const usuario = rows[0];
      const token   = gerarToken();
      const expiraEm = new Date(Date.now() + 15 * 60 * 1000);

      await db.query(
        'UPDATE tokens_recuperacao SET usado = TRUE WHERE user_id = ? AND usado = FALSE',
        [usuario.id]
      );

      await db.query(
        'INSERT INTO tokens_recuperacao (user_id, token, expira_em) VALUES (?, ?, ?)',
        [usuario.id, token, expiraEm]
      );

      await enviarEmailRecuperacao(email, token);
    }

    return res.json({ mensagem: 'Se o e-mail estiver cadastrado, um código foi enviado' });

  } catch (err) {
    console.error('Erro ao solicitar recuperação:', err.message);
    return res.status(500).json({ erro: 'Erro ao processar solicitação' });
  }
}

async function verificarToken(req, res) {
  try {
    const { email, token } = req.body;

    const [rows] = await db.query(
      `SELECT t.id, t.expira_em, t.usado
       FROM tokens_recuperacao t
       JOIN usuarios u ON u.id = t.user_id
       WHERE u.email = ? AND t.token = ?
       ORDER BY t.created_at DESC
       LIMIT 1`,
      [email, token]
    );

    if (rows.length === 0) {
      return res.status(400).json({ erro: 'Código inválido' });
    }

    const registro = rows[0];

    if (registro.usado) {
      return res.status(400).json({ erro: 'Código já utilizado' });
    }

    if (new Date() > new Date(registro.expira_em)) {
      return res.status(400).json({ erro: 'Código expirado' });
    }

    return res.json({ valido: true, tokenId: registro.id });

  } catch (err) {
    console.error('Erro ao verificar token:', err.message);
    return res.status(500).json({ erro: 'Erro ao verificar código' });
  }
}

async function redefinirSenha(req, res) {
  try {
    const { email, token, novaSenha } = req.body;

    if (!email || !token) {
      return res.status(400).json({ erro: 'Solicitação inválida' });
    }

    if (!novaSenha || novaSenha.length < 6) {
      return res.status(400).json({ erro: 'Senha deve ter pelo menos 6 caracteres' });
    }

    // Revalida o par email+token (não confia apenas em um id sequencial),
    // evitando que um tokenId adivinhado redefina a senha de outro usuário.
    const [rows] = await db.query(
      `SELECT t.id, t.user_id, t.expira_em, t.usado
       FROM tokens_recuperacao t
       JOIN usuarios u ON u.id = t.user_id
       WHERE u.email = ? AND t.token = ?
       ORDER BY t.created_at DESC
       LIMIT 1`,
      [email, token]
    );

    if (rows.length === 0) {
      return res.status(400).json({ erro: 'Solicitação inválida' });
    }

    const registro = rows[0];

    if (registro.usado) {
      return res.status(400).json({ erro: 'Código já utilizado' });
    }

    if (new Date() > new Date(registro.expira_em)) {
      return res.status(400).json({ erro: 'Código expirado' });
    }

    const senhaHash = await bcrypt.hash(novaSenha, 10);

    await db.query(
      'UPDATE usuarios SET senha_hash = ? WHERE id = ?',
      [senhaHash, registro.user_id]
    );

    await db.query(
      'UPDATE tokens_recuperacao SET usado = TRUE WHERE id = ?',
      [registro.id]
    );

    return res.json({ mensagem: 'Senha redefinida com sucesso' });

  } catch (err) {
    console.error('Erro ao redefinir senha:', err.message);
    return res.status(500).json({ erro: 'Erro ao redefinir senha' });
  }
}

module.exports = { solicitarRecuperacao, verificarToken, redefinirSenha };