const { getTabelaBanco } = require('./dictionary');

function buildSQL(iaJson) {
  const { tabelas, campos, filtros, joins } = iaJson;

  if (!tabelas || tabelas.length === 0) {
    throw new Error('Nenhuma tabela identificada');
  }

  // Troca nomes SAP pelos nomes reais do banco
  const tabelasReais = tabelas.map(t => {
    const real = getTabelaBanco(t);
    if (!real) throw new Error(`Tabela ${t} não existe no banco`);
    return { sap: t, real };
  });

  // Troca prefixos SAP pelos reais nos campos
  function traduzirCampo(campo) {
    if (!campo || typeof campo !== 'string') return campo;
    for (const { sap, real } of tabelasReais) {
      if (campo.startsWith(`${sap}.`)) {
        return campo.replace(`${sap}.`, `${real}.`);
      }
    }
    return campo;
  }

  // SELECT
  const selectCampos = campos && campos.length > 0
    ? campos.map(traduzirCampo).join(', ')
    : tabelasReais.map(t => `${t.real}.*`).join(', ');

  let sql = `SELECT ${selectCampos}\nFROM ${tabelasReais[0].real}`;

  // JOINs — aceita array de objetos ou string simples
  if (joins && Array.isArray(joins)) {
    for (const j of joins) {
      const tabelaReal = getTabelaBanco(j.tabela) ?? j.tabela;
      const condicao   = traduzirCampo(j.on);
      sql += `\nJOIN ${tabelaReal} ON ${condicao}`;
    }
  } else if (typeof joins === 'string' && joins) {
    sql += `\nJOIN ${tabelasReais[1]?.real ?? ''} ON ${traduzirCampo(joins)}`;
  }

  // WHERE
  const wheres = [];

  if (filtros?.periodo_dias && filtros?.campo_data) {
    const campo = traduzirCampo(filtros.campo_data);
    wheres.push(
      `${campo} >= DATE_SUB(NOW(), INTERVAL ${filtros.periodo_dias} DAY)`
    );
  }

  if (filtros?.data_inicio && filtros?.data_fim && filtros?.campo_data) {
    const campo = traduzirCampo(filtros.campo_data);
    wheres.push(
      `${campo} BETWEEN '${filtros.data_inicio}' AND '${filtros.data_fim}'`
    );
  }

  if (filtros?.where_extra && typeof filtros.where_extra === 'string') {
    wheres.push(traduzirCampo(filtros.where_extra));
  }

  if (wheres.length > 0) {
    sql += `\nWHERE ${wheres.join('\n  AND ')}`;
  }

  sql += '\nLIMIT 1000';

  return sql;
}

module.exports = { buildSQL };