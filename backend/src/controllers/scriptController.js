const { buildDictionaryText } = require('../sap/dictionary');
const { buildSQL } = require('../sap/sqlBuilder');
const db = require('../db/connection');

// System prompt — fica aqui no controller, não no Flutter
const SYSTEM_PROMPT = `Você é um assistente especialista em SAP e SQL.
Sua única função é interpretar perguntas de negócio em português
e retornar um JSON estruturado para geração de queries SQL.

TABELAS DISPONÍVEIS:
{{DICIONARIO}}

REGRAS OBRIGATÓRIAS:
- Responda APENAS com JSON puro, sem texto, sem markdown, sem explicação
- Use somente as tabelas listadas acima
- Se a pergunta não puder ser respondida com as tabelas disponíveis,
  retorne exatamente: {"erro": "Tabela não disponível para essa consulta"}

FORMATO DE RESPOSTA:
{
  "intencao": "consulta",
  "tabelas": ["AFKO"],
  "campos": ["AFKO.AUFNR", "AFKO.GAMNG"],
  "filtros": {
    "periodo_dias": 90,
    "campo_data": "AFKO.GSTRI"
  },
  "join": null,
  "descricao": "Volume de produção dos últimos 3 meses"
}`;

async function gerarScript(req, res) {
  try {
    const { pergunta } = req.body;
    const userId = req.user.id; // vem do middleware JWT

    if (!pergunta || pergunta.trim() === '') {
      return res.status(400).json({ erro: 'Pergunta não pode ser vazia' });
    }

    // Injeta o dicionário no system prompt
    const systemComDicionario = SYSTEM_PROMPT.replace(
      '{{DICIONARIO}}',
      buildDictionaryText()
    );

    // Chama a Claude API
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': process.env.ANTHROPIC_API_KEY,   // <-- vem do .env
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: 'claude-sonnet-4-20250514',
        max_tokens: 1000,
        system: systemComDicionario,         // <-- aqui vai o prompt
        messages: [
          { role: 'user', content: pergunta } // <-- aqui vai a pergunta do usuário
        ]
      })
    });

    if (!response.ok) {
      throw new Error(`Erro na Claude API: ${response.status}`);
    }

    const data = await response.json();
    const textoResposta = data.content[0].text;

    // Parse do JSON retornado pela IA
    let iaJson;
    try {
      iaJson = JSON.parse(textoResposta);
    } catch {
      throw new Error('A IA não retornou um JSON válido');
    }

    // Verifica se a IA disse que não tem tabela
    if (iaJson.erro) {
      return res.status(400).json({ erro: iaJson.erro });
    }

    // Monta o SQL a partir do JSON
    const sql = buildSQL(iaJson);

    // Salva no histórico do MySQL
    await db.query(
      'INSERT INTO historico (user_id, pergunta, sql_gerado) VALUES (?, ?, ?)',
      [userId, pergunta, sql]
    );

    // Retorna pro Flutter
    return res.json({
      sql,
      descricao: iaJson.descricao,
      tabelas: iaJson.tabelas
    });

  } catch (err) {
    console.error('Erro ao gerar script:', err.message);
    return res.status(500).json({ erro: 'Erro interno ao processar a pergunta' });
  }
}

module.exports = { gerarScript };