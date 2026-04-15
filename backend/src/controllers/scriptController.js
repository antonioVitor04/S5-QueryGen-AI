const { buildDictionaryText } = require('../sap/dictionary');
const { buildSQL } = require('../sap/sqlBuilder');
const db = require('../db/connection');

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
    const userId = req.user.id;

    if (!pergunta || pergunta.trim() === '') {
      return res.status(400).json({ erro: 'Pergunta não pode ser vazia' });
    }

    const systemComDicionario = SYSTEM_PROMPT.replace(
      '{{DICIONARIO}}',
      buildDictionaryText()
    );

    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': process.env.ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: 'claude-haiku-4-5-20251001',
        max_tokens: 1000,
        system: systemComDicionario,
        messages: [
          { role: 'user', content: pergunta }
        ]
      })
    });

    if (!response.ok) {
      const erroDetalhado = await response.json();
      console.error('Erro da Claude API:', JSON.stringify(erroDetalhado, null, 2));
      throw new Error(`Erro na Claude API: ${response.status}`);
    }

    const data = await response.json();
    const textoResposta = data.content[0].text;
    console.log('Resposta da IA:', textoResposta);

    let iaJson;
try {
  // Remove ```json, ``` e espaços extras que a IA às vezes coloca
  const textoLimpo = textoResposta
    .replace(/```json/g, '')
    .replace(/```/g, '')
    .trim();

  iaJson = JSON.parse(textoLimpo);
} catch {
  console.error('IA não retornou JSON válido:', textoResposta);
  throw new Error('A IA não retornou um JSON válido');
}

    if (iaJson.erro) {
      return res.status(400).json({ erro: iaJson.erro });
    }

    const sql = buildSQL(iaJson);

    await db.query(
      'INSERT INTO historico (user_id, pergunta, sql_gerado) VALUES (?, ?, ?)',
      [userId, pergunta, sql]
    );

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