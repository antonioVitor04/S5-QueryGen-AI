const db = require('../db/connection');
const bcrypt = require('bcrypt');
const { enviarEmailRecuperacao } = require('../services/emailService');

// Gera código de 6 dígitos
function gerarToken() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// PASSO 1 — usuário informa o email, recebe o código
async function solicitarRecuperacao(req, res) {
  try {
    const { email } = req.body;

    const [rows] = await db.query(
      'SELECT id FROM usuarios WHERE email = ?',
      [email]
    );

    // Retorna sucesso mesmo se email não existir
    // (evita que alguém descubra quais emails estão cadastrados)
    if (rows.length === 0) {
      return res.json({ mensagem: 'Se o email existir, você receberá o código.' });
    }

    const usuario = rows[0];
    const token = gerarToken();
    const expiraEm = new Date(Date.now() + 15 * 60 * 1000); // 15 minutos

    // Invalida tokens anteriores desse usuário
    await db.query(
      'UPDATE tokens_recuperacao SET usado = TRUE WHERE user_id = ? AND usado = FALSE',
      [usuario.id]
    );

    // Salva o novo token
    await db.query(
      'INSERT INTO tokens_recuperacao (user_id, token, expira_em) VALUES (?, ?, ?)',
      [usuario.id, token, expiraEm]
    );

    // Envia o email
    await enviarEmailRecuperacao(email, token);

    return res.json({ mensagem: 'Se o email existir, você receberá o código.' });

  } catch (err) {
    console.error('Erro ao solicitar recuperação:', err.message);
    return res.status(500).json({ erro: 'Erro ao processar solicitação' });
  }
}

// PASSO 2 — usuário digita o código de 6 dígitos no app
async function verificarToken(req, res) {
  try {
    const { email, token } = req.body;

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
      return res.status(400).json({ erro: 'Código inválido' });
    }

    const registro = rows[0];

    if (registro.usado) {
      return res.status(400).json({ erro: 'Código já utilizado' });
    }

    if (new Date() > new Date(registro.expira_em)) {
      return res.status(400).json({ erro: 'Código expirado' });
    }

    // Token válido — retorna um token temporário pro app avançar para a tela de nova senha
    // Não marca como usado ainda — só marca quando a senha for de fato alterada
    return res.json({
      valido: true,
      tokenId: registro.id  // o app guarda esse id para a próxima etapa
    });

  } catch (err) {
    console.error('Erro ao verificar token:', err.message);
    return res.status(500).json({ erro: 'Erro ao verificar código' });
  }
}

// PASSO 3 — usuário define a nova senha
async function redefinirSenha(req, res) {
  try {
    const { tokenId, novaSenha } = req.body;

    if (!novaSenha || novaSenha.length < 6) {
      return res.status(400).json({ erro: 'Senha deve ter pelo menos 6 caracteres' });
    }

    // Busca o token pelo id, checa se ainda é válido
    const [rows] = await db.query(
      'SELECT user_id, expira_em, usado FROM tokens_recuperacao WHERE id = ?',
      [tokenId]
    );

    if (rows.length === 0) {
      return res.status(400).json({ erro: 'Solicitação inválida' });
    }

    const registro = rows[0];

    if (registro.usado) {
      return res.status(400).json({ erro: 'Este código já foi utilizado' });
    }

    if (new Date() > new Date(registro.expira_em)) {
      return res.status(400).json({ erro: 'Código expirado' });
    }

    // Atualiza a senha
    const senhaHash = await bcrypt.hash(novaSenha, 10);
    await db.query(
      'UPDATE usuarios SET senha_hash = ? WHERE id = ?',
      [senhaHash, registro.user_id]
    );

    // Marca o token como usado para não poder reutilizar
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