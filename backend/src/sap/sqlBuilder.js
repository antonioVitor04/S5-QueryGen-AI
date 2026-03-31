// Recebe o objeto JSON que a Claude retornou e monta um SELECT válido
function buildSQL(iaJson) {
  const { tabelas, campos, filtros, join } = iaJson;

  if (!tabelas || tabelas.length === 0) {
    throw new Error("Nenhuma tabela identificada na resposta da IA");
  }

  // SELECT com os campos pedidos (ou * se não especificado)
  const selectCampos = campos && campos.length > 0
    ? campos.join(', ')
    : tabelas.map(t => `${t}.*`).join(', ');

  // FROM com as tabelas
  let sql = `SELECT ${selectCampos}\nFROM ${tabelas[0]}`;

  // JOIN se houver mais de uma tabela
  if (tabelas.length > 1 && join) {
    for (let i = 1; i < tabelas.length; i++) {
      sql += `\nJOIN ${tabelas[i]} ON ${join}`;
    }
  }

  // WHERE com os filtros de período
  const wheres = [];

  if (filtros?.periodo_dias && filtros?.campo_data) {
    wheres.push(
      `${filtros.campo_data} >= DATE_SUB(NOW(), INTERVAL ${filtros.periodo_dias} DAY)`
    );
  }

  if (filtros?.campo_data && filtros?.data_inicio && filtros?.data_fim) {
    wheres.push(
      `${filtros.campo_data} BETWEEN '${filtros.data_inicio}' AND '${filtros.data_fim}'`
    );
  }

  if (wheres.length > 0) {
    sql += `\nWHERE ${wheres.join('\n  AND ')}`;
  }

  // Limite de segurança para não explodir o banco
  sql += '\nLIMIT 1000';

  return sql;
}

module.exports = { buildSQL };