const db = require('../db/connection');
const bcrypt = require('bcrypt');
const { enviarEmailRecuperacao } = require('../services/emailService');

function gerarToken() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

async function solicitarRecuperacao(req, res) {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ erro: 'E-mail obrigatório' });

    const [rows] = await db.query(
      'SELECT id FROM usuarios WHERE email = ?', [email]
    );

    // Agora retorna erro explícito se email não existir
    if (rows.length === 0) {
      return res.status(404).json({ erro: 'E-mail não cadastrado' });
    }

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

    return res.json({ mensagem: 'Código enviado com sucesso' });

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
    const { tokenId, novaSenha } = req.body;

    if (!novaSenha || novaSenha.length < 6) {
      return res.status(400).json({ erro: 'Senha deve ter pelo menos 6 caracteres' });
    }

    const [rows] = await db.query(
      'SELECT user_id, expira_em, usado FROM tokens_recuperacao WHERE id = ?',
      [tokenId]
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
      [tokenId]
    );

    return res.json({ mensagem: 'Senha redefinida com sucesso' });

  } catch (err) {
    console.error('Erro ao redefinir senha:', err.message);
    return res.status(500).json({ erro: 'Erro ao redefinir senha' });
  }
}

module.exports = { solicitarRecuperacao, verificarToken, redefinirSenha };