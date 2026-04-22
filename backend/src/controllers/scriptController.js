const { buildDictionaryText } = require('../sap/dictionary');
const { buildSQL }            = require('../sap/sqlBuilder');
const db                      = require('../db/connection');

const SYSTEM_PROMPT = `Você é um especialista em SAP e SQL com 20 anos de experiência.
Sua tarefa é interpretar perguntas de negócio em português e retornar um JSON
estruturado para geração de queries SQL em um banco MySQL.

TABELAS DISPONÍVEIS NO BANCO:
{{DICIONARIO}}

════════════════════════════════════════
SCHEMA DO JSON DE RESPOSTA (obrigatório)
════════════════════════════════════════

{
  "intencao":  string,           // sempre "consulta"
  "tabelas":   string[],         // nomes SAP das tabelas usadas (ex: ["EKKO", "EKPO"])
  "campos":    string[],         // campos no formato TABELA.CAMPO ou FUNÇÃO(TABELA.CAMPO) AS alias
  "joins":     JoinObj[],        // array de objetos de join (vazio se tabela única)
  "filtros":   FiltroObj,        // objeto de filtros (vazio {} se nenhum)
  "group_by":  string | null,    // campo(s) para GROUP BY — OBRIGATÓRIO quando usar COUNT/SUM/AVG
  "grafico":   "pizza"|"linha"|"barra",
  "eixo_x":    string,           // nome da coluna sem prefixo (eixo horizontal ou fatia)
  "eixo_y":    string,           // nome da coluna numérica sem prefixo
  "descricao": string            // descrição curta da consulta em português
}

JoinObj: { "tabela": string, "on": string }
FiltroObj: {
  "periodo_dias"?: number,   // filtra pelos últimos N dias
  "campo_data"?:  string,    // campo de data para o filtro (formato TABELA.CAMPO)
  "data_inicio"?: string,    // formato YYYY-MM-DD
  "data_fim"?:    string,    // formato YYYY-MM-DD
  "where_extra"?: string     // condição WHERE adicional (formato TABELA.CAMPO = 'valor')
}

════════════════════════════════════════════════════════
REGRAS CRÍTICAS — VIOLÁ-LAS CAUSA ERRO NO BANCO DE DADOS
════════════════════════════════════════════════════════

REGRA 1 — GROUP BY obrigatório com agregação:
  Se qualquer campo em "campos" contiver COUNT(), SUM(), AVG(), MAX() ou MIN(),
  o campo "group_by" DEVE conter todos os campos não-agregados do SELECT.
  Nunca omita o group_by quando usar funções de agregação.

REGRA 2 — Formato de campos:
  Campos simples:    "TABELA.CAMPO"              → ex: "AFKO.GAMNG"
  Campos agregados:  "FUNÇÃO(TABELA.CAMPO) AS alias" → ex: "COUNT(QMEL.QMNUM) AS quantidade"
  Nunca use alias sem AS. Nunca omita o prefixo da tabela dentro de funções.

REGRA 3 — Joins:
  O campo "on" DEVE ser uma string simples: "TABELA1.CAMPO = TABELA2.CAMPO"
  Nunca use objeto dentro de "on". A primeira tabela de "tabelas" é sempre a do FROM.

REGRA 4 — Escolha do gráfico:
  "pizza"  → distribuição percentual entre categorias (até 8 grupos)
  "linha"  → evolução ao longo do tempo (campos de data no eixo X)
  "barra"  → comparação de quantidades entre categorias (sem dimensão temporal)

REGRA 5 — Tabela não disponível:
  Se a pergunta não puder ser respondida com as tabelas acima, retorne EXATAMENTE:
  {"erro": "Tabela não disponível para essa consulta"}

REGRA 6 — Formato da resposta:
  Retorne APENAS JSON puro. Sem texto antes ou depois. Sem markdown. Sem explicações.

══════════════════════════════════════
EXEMPLOS (few-shot) — siga este padrão
══════════════════════════════════════

Pergunta: "Distribuição de notificações de qualidade por status"
Resposta:
{
  "intencao": "consulta",
  "tabelas": ["QMEL"],
  "campos": ["QMEL.STAT", "COUNT(QMEL.QMNUM) AS quantidade"],
  "joins": [],
  "filtros": {},
  "group_by": "QMEL.STAT",
  "grafico": "pizza",
  "eixo_x": "STAT",
  "eixo_y": "quantidade",
  "descricao": "Distribuição de notificações de qualidade por status"
}

---

Pergunta: "Volume de produção dos últimos 3 meses"
Resposta:
{
  "intencao": "consulta",
  "tabelas": ["AFKO"],
  "campos": ["AFKO.GSTRI", "SUM(AFKO.GAMNG) AS total_produzido"],
  "joins": [],
  "filtros": { "periodo_dias": 90, "campo_data": "AFKO.GSTRI" },
  "group_by": "AFKO.GSTRI",
  "grafico": "linha",
  "eixo_x": "GSTRI",
  "eixo_y": "total_produzido",
  "descricao": "Volume de produção dos últimos 3 meses"
}

---

Pergunta: "Faturamento do último mês por cliente"
Resposta:
{
  "intencao": "consulta",
  "tabelas": ["VBRK", "KNA1"],
  "campos": ["KNA1.NAME1", "SUM(VBRK.NETWR) AS total_faturado"],
  "joins": [{ "tabela": "KNA1", "on": "VBRK.KUNAG = KNA1.KUNNR" }],
  "filtros": { "periodo_dias": 30, "campo_data": "VBRK.FKDAT" },
  "group_by": "KNA1.NAME1",
  "grafico": "barra",
  "eixo_x": "NAME1",
  "eixo_y": "total_faturado",
  "descricao": "Faturamento do último mês agrupado por cliente"
}

---

Pergunta: "Pedidos de compra por fornecedor nos últimos 90 dias"
Resposta:
{
  "intencao": "consulta",
  "tabelas": ["EKKO", "EKPO", "LFA1"],
  "campos": ["LFA1.NAME1", "COUNT(EKKO.EBELN) AS total_pedidos", "SUM(EKPO.MENGE) AS total_quantidade"],
  "joins": [
    { "tabela": "EKPO", "on": "EKKO.EBELN = EKPO.EBELN" },
    { "tabela": "LFA1", "on": "EKKO.LIFNR = LFA1.LIFNR" }
  ],
  "filtros": { "periodo_dias": 90, "campo_data": "EKKO.BEDAT" },
  "group_by": "LFA1.NAME1",
  "grafico": "barra",
  "eixo_x": "NAME1",
  "eixo_y": "total_pedidos",
  "descricao": "Pedidos de compra por fornecedor nos últimos 90 dias"
}

---

Pergunta: "Estoque atual por material"
Resposta:
{
  "intencao": "consulta",
  "tabelas": ["MARD", "MARA"],
  "campos": ["MARA.MAKTX", "SUM(MARD.LABST) AS estoque_total"],
  "joins": [{ "tabela": "MARA", "on": "MARD.MATNR = MARA.MATNR" }],
  "filtros": {},
  "group_by": "MARA.MAKTX",
  "grafico": "barra",
  "eixo_x": "MAKTX",
  "eixo_y": "estoque_total",
  "descricao": "Estoque atual agrupado por material"
}

---

Pergunta: "Movimentações de estoque recentes"
Resposta:
{
  "intencao": "consulta",
  "tabelas": ["MSEG"],
  "campos": ["MSEG.BUDAT", "MSEG.BWART", "MSEG.MATNR", "MSEG.MENGE", "MSEG.DMBTR"],
  "joins": [],
  "filtros": { "periodo_dias": 30, "campo_data": "MSEG.BUDAT" },
  "group_by": null,
  "grafico": "linha",
  "eixo_x": "BUDAT",
  "eixo_y": "MENGE",
  "descricao": "Movimentações de estoque dos últimos 30 dias"
}

---

Pergunta: "Ordens de manutenção por equipamento"
Resposta:
{
  "intencao": "consulta",
  "tabelas": ["AUFK"],
  "campos": ["AUFK.EQUNR", "COUNT(AUFK.AUFNR) AS total_ordens"],
  "joins": [],
  "filtros": {},
  "group_by": "AUFK.EQUNR",
  "grafico": "barra",
  "eixo_x": "EQUNR",
  "eixo_y": "total_ordens",
  "descricao": "Total de ordens de manutenção por equipamento"
}`;

// Limpa markdown que o modelo às vezes adiciona
function limparJSON(texto) {
  return texto
    .replace(/```json\s*/gi, '')
    .replace(/```\s*/g, '')
    .trim();
}

// Valida que o JSON tem os campos obrigatórios
function validarResposta(obj) {
  if (obj.erro) return; // erro intencional da IA — tudo certo
  if (!obj.tabelas || !Array.isArray(obj.tabelas) || obj.tabelas.length === 0) {
    throw new Error('JSON da IA sem campo "tabelas"');
  }
  if (!obj.campos || !Array.isArray(obj.campos) || obj.campos.length === 0) {
    throw new Error('JSON da IA sem campo "campos"');
  }
}

async function gerarScript(req, res) {
  const { pergunta } = req.body;
  const userId       = req.user?.id;

  // ── Validação de entrada ──────────────────────────────────
  if (!pergunta || typeof pergunta !== 'string' || !pergunta.trim()) {
    return res.status(400).json({ erro: 'Pergunta não pode ser vazia' });
  }

  if (pergunta.trim().length > 500) {
    return res.status(400).json({ erro: 'Pergunta muito longa (máx. 500 caracteres)' });
  }

  try {
    // ── Chama a Claude API ────────────────────────────────────
    const systemComDicionario = SYSTEM_PROMPT.replace(
      '{{DICIONARIO}}',
      buildDictionaryText()
    );

    const claudeRes = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type':    'application/json',
        'x-api-key':       process.env.ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({
        model:      'claude-haiku-4-5-20251001',
        max_tokens: 1500,
        system:     systemComDicionario,
        messages:   [{ role: 'user', content: pergunta.trim() }],
      }),
    });

    if (!claudeRes.ok) {
      const erroApi = await claudeRes.json().catch(() => ({}));
      console.error('Erro Claude API:', erroApi);
      const msg = erroApi?.error?.message ?? `Status ${claudeRes.status}`;
      return res.status(502).json({ erro: `Erro na API de IA: ${msg}` });
    }

    const claudeData   = await claudeRes.json();
    const textoResposta = claudeData?.content?.[0]?.text;

    if (!textoResposta) {
      return res.status(502).json({ erro: 'IA retornou resposta vazia' });
    }

    console.log('Resposta bruta da IA:', textoResposta);

    // ── Parse do JSON ─────────────────────────────────────────
    let iaJson;
    try {
      iaJson = JSON.parse(limparJSON(textoResposta));
    } catch {
      console.error('JSON inválido:', textoResposta);
      return res.status(502).json({ erro: 'IA retornou formato inválido' });
    }

    validarResposta(iaJson);

    // ── Erro semântico da IA (tabela não disponível) ──────────
    if (iaJson.erro) {
      return res.status(400).json({ erro: iaJson.erro });
    }

    // ── Monta o SQL ───────────────────────────────────────────
    let sql;
    try {
      sql = buildSQL(iaJson);
    } catch (buildErr) {
      console.error('Erro ao montar SQL:', buildErr.message);
      return res.status(400).json({ erro: `Erro ao montar consulta: ${buildErr.message}` });
    }

    console.log('SQL gerado:', sql);

    // ── Executa no banco ──────────────────────────────────────
    let dados = [];
    try {
      const [rows] = await db.query(sql);
      dados = rows;
      console.log(`Query retornou ${dados.length} registros`);
    } catch (sqlErr) {
      console.error('Erro ao executar SQL:', sqlErr.message);
      // Não falha o request — retorna SQL sem dados
    }

    // ── Salva no histórico ────────────────────────────────────
    try {
      await db.query(
        `INSERT INTO historico
         (user_id, pergunta, sql_gerado, grafico, eixo_x, eixo_y, descricao)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          userId,
          pergunta.trim(),
          sql,
          iaJson.grafico   ?? 'barra',
          iaJson.eixo_x    ?? null,
          iaJson.eixo_y    ?? null,
          iaJson.descricao ?? pergunta.trim(),
        ]
      );
    } catch (dbErr) {
      // Não falha o request se o histórico der erro
      console.error('Erro ao salvar histórico:', dbErr.message);
    }

    // ── Resposta ──────────────────────────────────────────────
    return res.json({
      sql,
      dados,
      grafico:   iaJson.grafico   ?? 'barra',
      eixo_x:    iaJson.eixo_x    ?? null,
      eixo_y:    iaJson.eixo_y    ?? null,
      descricao: iaJson.descricao ?? pergunta.trim(),
      tabelas:   iaJson.tabelas   ?? [],
    });

  } catch (err) {
    console.error('Erro inesperado:', err.message);
    return res.status(500).json({ erro: 'Erro interno ao processar a pergunta' });
  }
}

module.exports = { gerarScript };