const { getTabelaBanco } = require('./dictionary');

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
    const tUpper = t.toUpperCase().trim();
    const real   = getTabelaBanco(tUpper);
    if (!real) throw new Error(`Tabela SAP "${tUpper}" não existe no banco`);
    mapa[tUpper] = real;
  }
  return mapa;
}

function traduzir(str, mapa) {
  if (!str || typeof str !== 'string') return str ?? '';
  let resultado = str;
  for (const [sap, real] of Object.entries(mapa)) {
    resultado = resultado.replace(new RegExp(`\\b${sap}\\.`, 'gi'), `${real}.`);
  }
  return resultado;
}

function buildSQL(iaJson) {
  validarIaJson(iaJson);

  const { tabelas, campos, filtros, joins, group_by } = iaJson;
  const mapa            = buildMapaTabelas(tabelas);
  const tabelaPrincipal = mapa[tabelas[0].toUpperCase()];

  // SELECT
  const selectCampos = campos
    .map(c => traduzir(c, mapa))
    .join(', ');

  let sql = `SELECT ${selectCampos}\nFROM ${tabelaPrincipal}`;

  // JOINs
  if (Array.isArray(joins) && joins.length > 0) {
    for (const j of joins) {
      if (!j?.tabela || !j?.on) continue;
      const tabelaReal = getTabelaBanco(j.tabela.toUpperCase()) ?? j.tabela;
      const condicao   = traduzir(j.on, mapa);
      sql += `\nJOIN ${tabelaReal} ON ${condicao}`;
    }
  }

  // WHERE
  const wheres = [];

  if (filtros?.periodo_dias && filtros?.campo_data) {
    const dias  = parseInt(filtros.periodo_dias, 10);
    const campo = traduzir(filtros.campo_data, mapa);
    if (!isNaN(dias) && campo) {
      wheres.push(`${campo} >= DATE_SUB(NOW(), INTERVAL ${dias} DAY)`);
    }
  }

  if (filtros?.data_inicio && filtros?.data_fim && filtros?.campo_data) {
    const campo  = traduzir(filtros.campo_data, mapa);
    const inicio = filtros.data_inicio.replace(/[^0-9-]/g, '');
    const fim    = filtros.data_fim.replace(/[^0-9-]/g, '');
    if (campo && inicio && fim) {
      wheres.push(`${campo} BETWEEN '${inicio}' AND '${fim}'`);
    }
  }

  if (filtros?.where_extra && typeof filtros.where_extra === 'string') {
    wheres.push(traduzir(filtros.where_extra, mapa));
  }

  if (wheres.length > 0) {
    sql += `\nWHERE ${wheres.join('\n  AND ')}`;
  }

  // GROUP BY — vem da IA, só traduz
  if (group_by && typeof group_by === 'string' && group_by.trim()) {
    sql += `\nGROUP BY ${traduzir(group_by.trim(), mapa)}`;
  }

  sql += '\nLIMIT 1000';

  return sql;
}

module.exports = { buildSQL };