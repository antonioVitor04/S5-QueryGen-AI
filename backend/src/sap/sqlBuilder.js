const { getTabelaBanco, sapDictionary } = require('./dictionary');

const FUNCOES_PERMITIDAS    = ['COUNT', 'SUM', 'AVG', 'MIN', 'MAX'];
// Ordem importa: operadores de 2 caracteres antes dos de 1 caractere.
const OPERADORES_PERMITIDOS = ['!=', '<>', '>=', '<=', '=', '>', '<', 'LIKE'];

function validarIaJson(iaJson) {
  if (!iaJson || typeof iaJson !== 'object') {
    throw new Error('Resposta da IA inválida');
  }
  if (!Array.isArray(iaJson.tabelas) || iaJson.tabelas.length === 0) {
    throw new Error('Nenhuma tabela identificada pela IA');
  }
  if (!Array.isArray(iaJson.campos) || iaJson.campos.length === 0) {
    throw new Error('Nenhum campo identificado pela IA');
  }
}

function buildMapaTabelas(tabelas) {
  const mapa = {};
  for (const t of tabelas) {
    if (typeof t !== 'string') throw new Error('Tabela inválida retornada pela IA');
    const tUpper = t.toUpperCase().trim();
    const real   = getTabelaBanco(tUpper);
    if (!real) throw new Error(`Tabela SAP "${tUpper}" não existe no banco`);
    mapa[tUpper] = real;
  }
  return mapa;
}

// Valida "TABELA.CAMPO" contra as tabelas da consulta e o dicionário SAP.
// Retorna o nome já traduzido para o banco real: "tabela_real.CAMPO".
function validarTabelaCampo(expr, mapa) {
  if (typeof expr !== 'string') throw new Error('Campo inválido retornado pela IA');
  const m = /^([A-Za-z_][A-Za-z0-9_]*)\.([A-Za-z_][A-Za-z0-9_]*)$/.exec(expr.trim());
  if (!m) throw new Error(`Campo em formato inválido: "${expr}"`);

  const [, tabela, campo]  = m;
  const tabelaUpper        = tabela.toUpperCase();
  const campoUpper         = campo.toUpperCase();
  const tabelaReal         = mapa[tabelaUpper];
  if (!tabelaReal) throw new Error(`Tabela "${tabela}" não faz parte da consulta`);

  const camposValidos = sapDictionary[tabelaUpper]?.campos ?? {};
  if (!camposValidos[campoUpper]) {
    throw new Error(`Campo "${campo}" não existe na tabela ${tabela}`);
  }

  return `${tabelaReal}.${campoUpper}`;
}

// "TABELA.CAMPO" ou "FUNÇÃO(TABELA.CAMPO) AS alias"
function validarCampoSelect(expr, mapa) {
  if (typeof expr !== 'string') throw new Error('Campo inválido retornado pela IA');
  const str = expr.trim();

  const comFuncao = /^([A-Za-z]+)\(([^()]+)\)\s+AS\s+([A-Za-z_][A-Za-z0-9_]*)$/i.exec(str);
  if (comFuncao) {
    const [, funcao, interior, alias] = comFuncao;
    if (!FUNCOES_PERMITIDAS.includes(funcao.toUpperCase())) {
      throw new Error(`Função "${funcao}" não permitida em "${expr}"`);
    }
    const campoTraduzido = validarTabelaCampo(interior, mapa);
    return `${funcao.toUpperCase()}(${campoTraduzido}) AS ${alias}`;
  }

  return validarTabelaCampo(str, mapa);
}

// "TABELA1.CAMPO = TABELA2.CAMPO"
function validarJoinOn(expr, mapa) {
  if (typeof expr !== 'string') throw new Error('Condição de join inválida');
  const m = /^(.+?)\s*=\s*(.+)$/.exec(expr.trim());
  if (!m) throw new Error(`Condição de join inválida: "${expr}"`);
  const esquerda = validarTabelaCampo(m[1], mapa);
  const direita  = validarTabelaCampo(m[2], mapa);
  return `${esquerda} = ${direita}`;
}

// Literal numérico ou string entre aspas simples (sem aspas internas).
function validarValorLiteral(valor) {
  const v = valor.trim();
  if (/^'[^']*'$/.test(v)) return v;
  if (/^-?\d+(\.\d+)?$/.test(v)) return v;
  throw new Error(`Valor inválido em condição: "${valor}"`);
}

// "TABELA.CAMPO <op> valor"
function validarCondicaoSimples(expr, mapa) {
  const opRegex = new RegExp(`^(.+?)\\s*(${OPERADORES_PERMITIDOS.join('|')})\\s*(.+)$`, 'i');
  const m = opRegex.exec(expr.trim());
  if (!m) throw new Error(`Condição inválida: "${expr}"`);
  const [, campo, operador, valor] = m;
  const campoTraduzido = validarTabelaCampo(campo, mapa);
  const valorValidado  = validarValorLiteral(valor);
  return `${campoTraduzido} ${operador.toUpperCase()} ${valorValidado}`;
}

// where_extra pode combinar condições simples com AND/OR.
function validarWhereExtra(expr, mapa) {
  if (typeof expr !== 'string' || !expr.trim()) return '';
  const partes = expr.split(/\s+(AND|OR)\s+/i);
  return partes
    .map((parte, i) => (i % 2 === 1 ? parte.toUpperCase() : validarCondicaoSimples(parte, mapa)))
    .join(' ');
}

// "TABELA.CAMPO, TABELA.CAMPO2"
function validarGroupBy(expr, mapa) {
  if (typeof expr !== 'string' || !expr.trim()) return '';
  return expr.split(',').map(c => validarTabelaCampo(c, mapa)).join(', ');
}

function validarData(data) {
  const v = String(data ?? '').trim();
  if (!/^\d{4}-\d{2}-\d{2}$/.test(v)) throw new Error(`Data inválida: "${data}"`);
  return v;
}

function buildSQL(iaJson) {
  validarIaJson(iaJson);

  const { tabelas, campos, filtros, joins, group_by } = iaJson;
  const mapa            = buildMapaTabelas(tabelas);
  const tabelaPrincipal = mapa[tabelas[0].toUpperCase().trim()];

  // SELECT
  const selectCampos = campos
    .map(c => validarCampoSelect(c, mapa))
    .join(', ');

  let sql = `SELECT ${selectCampos}\nFROM ${tabelaPrincipal}`;

  // JOINs
  if (Array.isArray(joins) && joins.length > 0) {
    for (const j of joins) {
      if (!j?.tabela || !j?.on) continue;
      if (typeof j.tabela !== 'string') throw new Error('Tabela de join inválida');
      const tabelaUpper = j.tabela.toUpperCase().trim();
      const tabelaReal  = mapa[tabelaUpper] ?? getTabelaBanco(tabelaUpper);
      if (!tabelaReal) throw new Error(`Tabela de join "${j.tabela}" não existe no banco`);
      if (!mapa[tabelaUpper]) mapa[tabelaUpper] = tabelaReal;
      const condicao = validarJoinOn(j.on, mapa);
      sql += `\nJOIN ${tabelaReal} ON ${condicao}`;
    }
  }

  // WHERE
  const wheres = [];

  if (filtros?.periodo_dias && filtros?.campo_data) {
    const dias  = parseInt(filtros.periodo_dias, 10);
    const campo = validarTabelaCampo(filtros.campo_data, mapa);
    if (!isNaN(dias) && dias > 0) {
      wheres.push(`${campo} >= DATE_SUB(NOW(), INTERVAL ${dias} DAY)`);
    }
  }

  if (filtros?.data_inicio && filtros?.data_fim && filtros?.campo_data) {
    const campo  = validarTabelaCampo(filtros.campo_data, mapa);
    const inicio = validarData(filtros.data_inicio);
    const fim    = validarData(filtros.data_fim);
    wheres.push(`${campo} BETWEEN '${inicio}' AND '${fim}'`);
  }

  if (filtros?.where_extra) {
    const condicao = validarWhereExtra(filtros.where_extra, mapa);
    if (condicao) wheres.push(condicao);
  }

  if (wheres.length > 0) {
    sql += `\nWHERE ${wheres.join('\n  AND ')}`;
  }

  // GROUP BY
  if (group_by) {
    const groupBy = validarGroupBy(group_by, mapa);
    if (groupBy) sql += `\nGROUP BY ${groupBy}`;
  }

  sql += '\nLIMIT 1000';

  return sql;
}

// Tabelas e colunas reais que podem aparecer em um SQL gerado por buildSQL().
const TABELAS_BANCO_VALIDAS = new Set(
  Object.values(sapDictionary).map(t => t.tabela_banco)
);
const COLUNAS_VALIDAS = new Set(
  Object.values(sapDictionary).flatMap(t => Object.keys(t.campos))
);

const PADROES_PROIBIDOS = /;|--|\/\*|\*\/|\bUNION\b|\bINFORMATION_SCHEMA\b|\bINTO\b|\bLOAD_FILE\b|\bSLEEP\s*\(/i;

// Defesa em profundidade: revalida um SQL já armazenado (gerado anteriormente
// por buildSQL) antes de reexecutá-lo, garantindo que só referencia tabelas e
// colunas conhecidas do dicionário SAP e não contém construções perigosas.
function validarSqlArmazenado(sql) {
  if (typeof sql !== 'string' || !sql.trim()) return false;

  if (!/^\s*SELECT\s/i.test(sql)) return false;
  if (PADROES_PROIBIDOS.test(sql)) return false;
  if ((sql.match(/\bSELECT\b/gi) || []).length > 1) return false;

  for (const m of sql.matchAll(/\b(?:FROM|JOIN)\s+([a-zA-Z_][a-zA-Z0-9_]*)/gi)) {
    if (!TABELAS_BANCO_VALIDAS.has(m[1])) return false;
  }

  for (const m of sql.matchAll(/\b[a-zA-Z_][a-zA-Z0-9_]*\.([A-Za-z_][A-Za-z0-9_]*)\b/g)) {
    if (!COLUNAS_VALIDAS.has(m[1].toUpperCase())) return false;
  }

  return true;
}

module.exports = { buildSQL, validarSqlArmazenado };
